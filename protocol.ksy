meta:
  id: Nano Light Net
  title: Nano Network Protocol
  endian: le

types:
    instances:
      item_count_int:
        value: (extensions & 0xf000) >> 12
        doc: |
          For node_id_ack, this is the number of representatives which the node represents.
