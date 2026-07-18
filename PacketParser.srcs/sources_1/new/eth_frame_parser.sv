// =============================================================================
// Module:  eth_frame_parser
//
// Strips the 14-byte Ethernet II header. Outputs L3 payload on m_axis.
//
//   Byte  0- 5  dst_mac
//   Byte  6-11  src_mac
//   Byte 12-13  EtherType  (must be 0x0800)
//   Byte 14+    L3 payload -> m_axis
//
// Drop conditions:
//   - dst_mac != cfg_mac AND dst_mac != FF:FF:FF:FF:FF:FF
//   - EtherType != 0x0800
// =============================================================================

`timescale 1ns / 1ps
`default_nettype none

module eth_frame_parser #(
    parameter int DATA_W           = 8
)(
    input  wire                 clk,
    input  wire                 rst_n,
    
    //AXIS Slave
    input  wire [DATA_W-1:0]    s_axis_tdata,
    input  wire                 s_axis_tvalid,
    output logic                s_axis_tready,
    input  wire                 s_axis_tlast,

    // AXIS  Master
    output logic [DATA_W-1:0]   m_axis_tdata,
    output logic                m_axis_tvalid,
    input  wire                 m_axis_tready,
    output logic                m_axis_tlast,

    // Config
    input  wire [47:0]          cfg_mac,

    // Sideband metadata
    output logic [47:0]         src_mac,
    output logic [47:0]         dst_mac,

    // Telemetry pulses
    output logic                frame_in,
    output logic                drop_frame
);

// FSM states
typedef enum logic [1:0] {
    S_HEADER,
    S_PAYLOAD,
    S_DROP
} state_t;

state_t state;
state_t next_state;

logic drop_ether;
logic [16:0] ethertype;

logic [6:0] byte_cnt;
always_ff @(posedge clk) begin
    if(!rst_n)
        byte_cnt <= 7'd0;
    else if(s_axis_tvalid && s_axis_tready)
        byte_cnt <= byte_cnt + 7'd1;
end

always_ff @(posedge clk) begin
    if(!rst_n)
        state <= S_HEADER;
    else
        state <= next_state;
end

always_comb begin
    next_state = state;
    case (state)
        S_HEADER: next_state = drop_ether ? S_DROP : (byte_cnt >= 14) ? S_PAYLOAD : S_HEADER;
        S_PAYLOAD: next_state = s_axis_tlast ? S_HEADER : S_PAYLOAD;
        S_DROP: next_state = s_axis_tlast ? S_HEADER : S_DROP;
    endcase
end

always_ff @(posedge clk) begin
    if(byte_cnt <= 5) begin
        dst_mac[{3'd5 - byte_cnt[2:0], 3'b111} -: 8] <= s_axis_tdata;
        //something should come here
     end
    else if(byte_cnt <= 11)
        src_mac[{4'd11 - byte_cnt[3:0], 3'b111} -: 8] <= s_axis_tdata;
    else if(byte_cnt <= 13)
        ethertype[{4'd13 - byte_cnt[3:0], 3'b111} -: 8] <= s_axis_tdata;
    else if(next_state == S_PAYLOAD) begin
        m_axis_tdata <= s_axis_tdata;
        m_axis_tvalid <= s_axis_tvalid;
        m_axis_tlast <= s_axis_tlast;
        s_axis_tready <= m_axis_tready;
    end
    else if(next_state == S_DROP) begin
        m_axis_tdata <= 0;
        m_axis_tvalid <= 0;
        m_axis_tlast <= 0;
        s_axis_tready <= 1;
    end
end

assign frame_in = (byte_cnt == 0) && s_axis_tvalid && s_axis_tready;
assign drop_frame = (state == S_HEADER) && s_axis_tvalid && s_axis_tready && drop_ether;
assign drop_ether = /*(byte_cnt == 14) && */((ethertype != 16'h0800) || ((dst_mac != cfg_mac) && (dst_mac != 48'hFFFFFFFFFFFF))); 

endmodule

`default_nettype wire
