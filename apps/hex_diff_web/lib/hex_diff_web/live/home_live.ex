defmodule HexDiffWeb.Live.HomeLive do
  use HexDiffWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       form_data: %{
         "package" => "",
         "version_1" => "",
         "version_2" => ""
       },
       result: ""
     )}
  end

  @impl true
  def handle_event("update_form", %{"form" => form_data}, socket) do
    # Update form data on each keystroke (real-time updates)
    {:noreply, assign(socket, form_data: form_data)}
  end

  def handle_event("submit_form", %{"form" => form_data}, socket) do
    # Handle form submission
    IO.inspect(form_data, label: "Form submitted")

    result = HexDiff.run(form_data["package"], form_data["version_1"], form_data["version_2"])

    # Update socket with new state
    {:noreply,
     assign(socket,
       # Clear form
       form_data: %{"name" => "", "email" => ""},
       result: result
     )}
  end

  def handle_event(name, _params, _socket) do
    IO.inspect(name)
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="p-6 max-w-[400px] mx-auto">
      <h1 class="text-2xl font-bold mb-6">LiveView without Schema</h1>
      <form phx-submit="submit_form" phx-change="update_form" class="space-y-4">
        <div>
          <label class="block text-sm font-medium mb-1">Package</label>
          <input
            type="text"
            name="form[package]"
            value={@form_data["package"]}
            class="w-full p-2 border rounded focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
          />

          <label class="block text-sm font-medium mb-1">Version 1</label>
          <input
            type="text"
            name="form[version_1]"
            value={@form_data["version_1"]}
            class="w-full p-2 border rounded focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
          />

          <label class="block text-sm font-medium mb-1">Version 2</label>
          <input
            type="text"
            name="form[version_2]"
            value={@form_data["version_2"]}
            class="w-full p-2 border rounded focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
          />
        </div>

        <button
          type="submit"
          class="w-full py-2 px-4 bg-blue-600 text-white font-medium rounded hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-500"
        >
          Submit Form
        </button>
      </form>
      <pre>
        <%= @result %>
      </pre>
    </div>
    """
  end
end
