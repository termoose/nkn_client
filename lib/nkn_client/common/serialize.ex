defmodule NknClient.Common.Serialize do
  def encode_uint8(integer) do
    <<integer::unsigned-integer-size(8)>> |> Base.encode16(case: :lower)
  end

  def encode_uint16(integer) do
    <<integer::little-unsigned-integer-size(16)>> |> Base.encode16(case: :lower)
  end

  def encode_uint32(integer) do
    <<integer::little-unsigned-integer-size(32)>> |> Base.encode16(case: :lower)
  end

  def encode_uint64(integer) do
    <<integer::little-unsigned-integer-size(64)>> |> Base.encode16(case: :lower)
  end

  def encode_uint(integer) do
    case integer do
      i when i < 0xFD ->
        encode_uint8(i)

      i when i < 0xFFFF ->
        "fd#{encode_uint16(i)}"

      i when i < 0xFFFFFFFF ->
        "fe#{encode_uint32(i)}"

      i ->
        "ff#{encode_uint64(i)}"
    end
  end

  def encode_bytes(bytes) do
    hex_bytes_length = bytes |> byte_size() |> encode_uint()
    hex_bytes = bytes |> Base.encode16(case: :lower)
    "#{hex_bytes_length}#{hex_bytes}"
  end
end
