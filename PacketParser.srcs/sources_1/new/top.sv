`timescale 1ns / 1ps
`default_nettype none

module top #(
    parameter int DATA_W = 8
)(
    // Clock / Reset
    input  wire clk,
    input  wire rst_n,

    // AXI-Stream Slave, ethernet data in
    input  wire [DATA_W-1:0] s_axis_tdata,
    input  wire s_axis_tvalid,
    output wire s_axis_tready,
    input  wire s_axis_tlast,

    // AXI-Stream Master, UPD payload out
    output wire [DATA_W-1:0] m_axis_tdata,
    output wire m_axis_tvalid,
    input  wire m_axis_tready,
    output wire m_axis_tlast,

    // Metadata
    output wire [47:0] meta_src_mac,
    output wire [47:0] meta_dst_mac,
    output wire [31:0] meta_src_ip,
    output wire [31:0] meta_dst_ip,
    output wire [15:0] meta_src_port,
    output wire [15:0] meta_dst_port,
    output wire [15:0] meta_udp_length,

    input  wire [11:0]          s_axil_awaddr,
    input  wire                 s_axil_awvalid,
    output wire                 s_axil_awready,
    input  wire [31:0]          s_axil_wdata,
    input  wire [3:0]           s_axil_wstrb,
    input  wire                 s_axil_wvalid,
    output wire                 s_axil_wready,
    output wire [1:0]           s_axil_bresp,
    output wire                 s_axil_bvalid,
    input  wire                 s_axil_bready,
    input  wire [11:0]          s_axil_araddr,
    input  wire                 s_axil_arvalid,
    output wire                 s_axil_arready,
    output wire [31:0]          s_axil_rdata,
    output wire [1:0]           s_axil_rresp,
    output wire                 s_axil_rvalid,
    input  wire                 s_axil_rready
);

// todo: add inter-module wires

// todo: add eth_frame_parser
// todo: add ipv4_parser
// todo: add udp_parser

endmodule

`default_nettype wire
