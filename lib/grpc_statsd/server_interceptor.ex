defmodule GRPCStatsd.ServerInterceptor do
  defmacro __using__(opts) do
    quote do
      @behaviour GRPC.ServerInterceptor

      @statsd unquote(opts[:statsd_module] || Statix)
      @time_unit unquote(opts[:time_unit] || :millisecond)
      @default_tags unquote(opts[:default_tags] || [])

      def init(opts) do
        opts
      end

      def call(req, %{grpc_type: grpc_type, __interface__: interface} = stream, next, opts) do
        tags = ["grpc_service:#{stream.service_name}", "grpc_method:#{stream.method_name}", "grpc_type:#{grpc_type}"|@default_tags]

        @statsd.increment("grpc.server.started_total", 1, tags: tags)

        req =
          if grpc_type == :client_stream || grpc_type == :bidi_stream do
            Stream.map(req, fn r ->
              @statsd.increment("grpc.server.msg_received_total", 1, tags: tags)
              r
            end)
          else
            req
          end

        send_reply = fn stream, reply ->
          stream = interface[:send_reply].(stream, reply)
          @statsd.increment("grpc.server.msg_sent_total", 1, tags: tags)
          stream
        end

        start = System.monotonic_time()
        result = next.(req, %{stream | __interface__: Map.put(interface, :send_reply, send_reply)})
        stop = System.monotonic_time()

        code =
          case result do
            {:ok, _} ->
              GRPC.Status.code_name(0)

            {:ok, _, _} ->
              GRPC.Status.code_name(0)

            {:error, %GRPC.RPCError{} = error} ->
              GRPC.Status.code_name(error.status)

            {:error, _} ->
              GRPC.Status.code_name(GRPC.Status.unknown())
          end

        tags_with_code = ["grpc_code:#{code}" | tags]
        @statsd.increment("grpc.server.handled_total", 1, tags: tags_with_code)

        time = System.convert_time_unit(stop - start, :native, @time_unit)
        @statsd.histogram("grpc.server.handled_latency", time, tags: tags_with_code)

        result
      end
    end
  end
end
