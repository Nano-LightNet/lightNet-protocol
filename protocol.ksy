meta:
  id: lightnano
  title: Nano Light Network Protocol
  endian: le
seq:
  - id: body
    doc: Message body whose content depends on block type in the header.
    type:
      switch-on: header.message_type
      cases:
        'enum_msgtype::node_id_req': msg_node_id_req
        'enum_msgtype::node_id_ack': node_id_ack
enums:
  # The protocol version covered by this specification
  protocol_version:
    1: value
  enum_msgtype:
    0x00: invalid
    0x01: node_id_req
    0x02: node_id_ack

types:
    instances:
      item_count_int:
        value: (extensions & 0x001f)
        doc: |
          For node_id_ack, this is the number of representatives which the node represents.
        cookie_flag:
          value: (extensions & 0x0001)
          doc: |
            If set, this is a node_id_req which contains a cookie.

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
