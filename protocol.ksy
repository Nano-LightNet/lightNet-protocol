meta:
  id: Nano Light Net
  title: Nano Network Protocol
  endian: le

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
        value: (extensions & 0x1f)
        doc: |
          For node_id_ack, this is the number of representatives which the node represents.
