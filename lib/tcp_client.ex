defmodule TcpClient do
  use GenServer

  def start_link(options \\ []) do
    GenServer.start_link(__MODULE__,options,[name: __MODULE__])
  end

  def init [] do
    {:ok,socket} = :gen_tcp.connect({127,0,0,1}, 6666, [:binary,{:packet,:line},{:active,true}])
    {:ok, %{address: "localhost",port: 6666,socket: socket}}
  end

  def init [address,port] do
    {:ok,socket} = :gen_tcp.connect(address, 6666, [:binary,{:packet,:line},{:active,true}])
    {:ok, %{address: address,port: port,socket: socket}}
  end

  def send_message message do
    GenServer.call __MODULE__, {:send,message}
  end


  def handle_call {:send,message}, _from, state do
    :gen_tcp.send state.socket,message
    {:reply,"success",state}
  end

  def handle_info({:tcp,_socket,packet},state) do
    IO.inspect packet, label: "server packet"
    {:noreply,state}
  end

  def handle_info({:tcp_closed,socket},state) do
    IO.inspect "Socket was closed"
    {:noreply,state}
  end

  def handle_info({:tcp_error,socket,reason},state) do
    IO.inspect socket,label: "connection closed dut to #{reason}"
    {:noreply,state}
  end
end


