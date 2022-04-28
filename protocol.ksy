meta:
  id: lightnano
  title: Nano Light Network Protocol
  endian: le
seq:
  - id: header
    doc: Message header with message type, version information and message-specific extension bits.
    type: message_header
  - id: body
    doc: Message body whose content depends on block type in the header.
    type: body(header.message_type)
  - id: signature
    size: 32
    type: packet_signature
    if: _root.header.message_type != enum_msgtype::node_id_req
    doc: Packet Signature = Blake2b(header + body, SharedSecret
enums:
  # The protocol version covered by this specification
  protocol_version:
    18: value
  lnet_version:
    1: value
  enum_msgtype:
    0x00: invalid
    0x01: node_id_req
    0x02: node_id_ack
  enum_network:
    0x41: network_test
    0x42: network_beta
    0x43: network_live

types:
  body:
    params:
      - id: message_type
        type: u1
        enum: enum_msgtype
    seq: 
    - id: body
      type:
        switch-on: message_type
        cases:
          'enum_msgtype::node_id_req': msg_node_id_req
          'enum_msgtype::node_id_ack': msg_node_id_ack
  message_header:
    seq:
      - id: magic
        contents: R
        doc: Protocol identifier. Always 'R'.
      - id: network_id
        type: u1
        enum: enum_network
        doc: Network ID 'A', 'B' or 'C' for test, beta or live network respectively.
      - id: version_max
        type: u1
        doc: Maximum version supported by the sending node
      - id: version_using
        type: u1
        doc: Version used by the sending node
      - id: version_min
        type: u1
        doc: Minimum version supported by the sending node
      - id: message_type
        type: u1
        enum: enum_msgtype
        doc: Message type
      - id: extensions
        type: u2le
        doc: Extensions bitfield
      - id: height
        type: u8be
        doc: Message Height (NodeIDReq doesn't use this header)
    instances:
      rep_count_int:
        value: (extensions & 0x001f)
        doc: For node_id_ack, this is the number of representatives which the node represents.
      cookie_flag:
        value: (extensions & 0x0001)
        doc: If set, this is a node_id_req which contains a cookie.
  msg_node_id_req:
    doc: A Node ID Request is a method to transmit NodeID of the current node, and a cookie if one wasn't sent before upgrade.
    seq:
      - id: nodeid
        size: 32
        doc: Account (node id)        
      - id: cookie
        if: _root.header.cookie_flag != 0
        size: 30
        doc: Per-endpoint random number
  msg_node_id_ack:
    doc: A Node ID Response which is sent when node has recieved NodeID and Cookie from other end.
    seq:
      - id: entry
        type: representative_entry
        repeat: until
        repeat-until: _index == _root.header.rep_count_int
    types:
      representative_entry:
        seq:
          - id: representative
            size: 32
            doc: Account
          - id: signature
            size: 64
  packet_signature:
    seq:
      - id: hmac
        type: hmac_input
        size: 32
    types:
      hmac_input:
        seq:
          - id: header
            size: 8
          - id: body
            type: body(_root.header.message_type)
          - id: cookie
            size: 30
            doc: Cookie provided in NodeIDHandshake (last 30 bytes) or NodeIDReq