-module(udp_server_handler_behavior).

-callback on_client_data(Socket :: port(), ClientIp :: atom(), ClientPort :: integer(), DataBin :: any()) ->
  noreplay.