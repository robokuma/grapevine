defmodule Metrics.TelnetInstrumenter do
  @moduledoc """
  Instrumentation for the telnet client
  """

  use Prometheus.Metric

  require Logger

  @doc false
  def setup() do
    events = [
      [:start],
      [:connection, :connected],
      [:connection, :failed],
      [:wont],
      [:dont],
      [:charset, :sent],
      [:charset, :accepted],
      [:charset, :rejected],
      [:line_mode, :sent],
      [:gmcp, :sent],
      [:gmcp, :received],
      [:mssp, :sent],
      [:term_type, :sent],
      [:term_type, :details],

      # mssp specific
      [:mssp, :failed],
      [:mssp, :option, :success],
      [:mssp, :text, :sent],
      [:mssp, :text, :success]
    ]

    events =
      Enum.map(events, fn event ->
        name = Enum.join(event, "_")

        Counter.declare(
          name: String.to_atom("grapevine_telnet_#{name}_count"),
          help: "Total count of tracking for telnet MSSP event #{name}"
        )

        [:grapevine, :telnet | event]
      end)

    :telemetry.attach_many("grapevine-telnet", events, &handle_event/4, nil)
  end

  def handle_event([:grapevine, :telnet, :start], _count, %{host: host, port: port}, _config) do
    Logger.debug(fn ->
      "Starting Telnet Client: #{host}:#{port}"
    end, type: :telnet)
    Counter.inc(name: :grapevine_telnet_start_count)
  end

  def handle_event([:grapevine, :telnet, :connection, :connected], _count, _metadata, _config) do
    Logger.debug("Connected to game", type: :telnet)
    Counter.inc(name: :grapevine_telnet_connection_connected_count)
  end

  def handle_event([:grapevine, :telnet, :connection, :failed], _count, metadata, _config) do
    Logger.debug(fn ->
      "Could not connect to a game - #{metadata[:error]}"
    end, type: :telnet)
    Counter.inc(name: :grapevine_telnet_connection_failed_count)
  end

  def handle_event([:grapevine, :telnet, :wont], _count, metadata, _config) do
    Logger.debug(fn ->
      "Rejecting a WONT #{metadata[:byte]}"
    end, type: :telnet)
    Counter.inc(name: :grapevine_telnet_wont_count)
  end

  def handle_event([:grapevine, :telnet, :dont], _count, metadata, _config) do
    Logger.debug(fn ->
      "Rejecting a DO #{metadata[:byte]}"
    end, type: :telnet)
    Counter.inc(name: :grapevine_telnet_dont_count)
  end

  def handle_event([:grapevine, :telnet, :charset, :sent], _count, _metadata, _config) do
    Logger.debug("Responding to CHARSET", type: :telnet)
    Counter.inc(name: :grapevine_telnet_charset_sent_count)
  end

  def handle_event([:grapevine, :telnet, :charset, :accepted], _count, _metadata, _config) do
    Logger.debug("Accepting charset", type: :telnet)
    Counter.inc(name: :grapevine_telnet_charset_accepted_count)
  end

  def handle_event([:grapevine, :telnet, :charset, :rejected], _count, _metadata, _config) do
    Logger.debug("Rejecting charset", type: :telnet)
    Counter.inc(name: :grapevine_telnet_charset_rejected_count)
  end

  def handle_event([:grapevine, :telnet, :gmcp, :sent], _count, _metadata, _config) do
    Logger.debug("Responding to GMCP", type: :telnet)
    Counter.inc(name: :grapevine_telnet_gmcp_sent_count)
  end

  def handle_event([:grapevine, :telnet, :gmcp, :received], _count, _metadata, _config) do
    Logger.debug("Received GMCP Message", type: :telnet)
    Counter.inc(name: :grapevine_telnet_gmcp_received_count)
  end

  def handle_event([:grapevine, :telnet, :mssp, :sent], _count, _metadata, _config) do
    Logger.debug("Sending MSSP via telnet option", type: :telnet)
    Counter.inc(name: :grapevine_telnet_mssp_sent_count)
  end

  def handle_event([:grapevine, :telnet, :line_mode, :sent], _count, _metadata, _config) do
    Logger.debug("Responding to LINEMODE", type: :telnet)
    Counter.inc(name: :grapevine_telnet_line_mode_sent_count)
  end

  def handle_event([:grapevine, :telnet, :term_type, :sent], _count, _metadata, _config) do
    Logger.debug("Responding to TTYPE", type: :telnet)
    Counter.inc(name: :grapevine_telnet_term_type_sent_count)
  end

  def handle_event([:grapevine, :telnet, :term_type, :details], _count, _metadata, _config) do
    Logger.debug("Responding to TTYPE request", type: :telnet)
  end

  def handle_event([:grapevine, :telnet, :mssp, :option, :success], _count, state, _config) do
    Logger.info("Received MSSP from #{state.host}:#{state.port} - option version", type: :telnet)
    Counter.inc(name: :grapevine_telnet_mssp_option_success_count)
  end

  def handle_event([:grapevine, :telnet, :mssp, :text, :sent], _count, _metadata, _config) do
    Logger.debug("Sending a text version of mssp request", type: :telnet)
    Counter.inc(name: :grapevine_telnet_mssp_text_sent_count)
  end

  def handle_event([:grapevine, :telnet, :mssp, :text, :success], _count, state, _config) do
    Logger.info("Received MSSP from #{state.host}:#{state.port} - text version", type: :telnet)
    Counter.inc(name: :grapevine_telnet_mssp_text_success_count)
  end

  def handle_event([:grapevine, :telnet, :mssp, :failed], _count, state, _config) do
    Logger.debug(
      fn ->
        "Terminating connection to #{state.host}:#{state.port} due to no MSSP being sent"
      end,
      type: :telnet
    )

    Counter.inc(name: :grapevine_telnet_mssp_failed_count)
  end
end
