Code.require_file("../../../installer/test/mix_helper.exs", __DIR__)

defmodule Mix.Tasks.Phx.Gen.DockerTest do
  use ExUnit.Case
  import MixHelper
  alias Mix.Tasks.Phx.Gen

  setup do
    Mix.Task.clear()
    :ok
  end

  test "generates channel" do
    in_tmp_project("generates docker and release files", fn ->
      # Ensure the `user_socket.ex` exists first.
      Gen.Docker.run([])

      assert_file("lib/phoenix/release.ex", fn file ->
        assert file =~ ~S|defmodule Phoenix.Release do|
        assert file =~ ~S|@app :phoenix|
      end)

      assert_file("Dockerfile", fn file ->
        assert file =~ ~S|COPY --from=builder --chown=nobody:root /app/_build/prod/rel/phoenix ./|
        assert file =~ ~S|CMD /app/bin/server|
      end)

      assert_file("Dockerfile", fn file ->
        assert file =~ ~S|COPY --from=builder --chown=nobody:root /app/_build/prod/rel/phoenix ./|
        assert file =~ ~S|CMD /app/bin/server|
      end)

      assert_file("rel/overlays/bin/migrate", fn file ->
        assert file =~ ~S|./phoenix eval Phoenix.Release.migrate|
      end)

      assert_file("rel/overlays/bin/server", fn file ->
        assert file =~ ~S|SERVER=true ./phoenix start|
      end)

      assert_file(".dockerignore")
      assert_file("rel/env.bat.eex")
      assert_file("rel/env.sh.eex")
      assert_file("rel/remote.vm.args.eex")
      assert_file("rel/vm.args.eex")

      assert_receive {:mix_shell, :info, ["* creating Dockerfile"]}
      assert_receive {:mix_shell, :info, ["* creating .dockerignore"]}
      assert_receive {:mix_shell, :info, ["* creating lib/phoenix/release.ex"]}
      assert_receive {:mix_shell, :info, ["* creating rel/env.bat.eex"]}
      assert_receive {:mix_shell, :info, ["* creating rel/env.sh.eex"]}
      assert_receive {:mix_shell, :info, ["* creating rel/remote.vm.args.eex"]}
      assert_receive {:mix_shell, :info, ["* creating rel/vm.args.eex"]}
      assert_receive {:mix_shell, :info, ["* creating rel/overlays/bin/migrate"]}
      assert_receive {:mix_shell, :info, ["* creating rel/overlays/bin/server"]}
      assert_receive {:mix_shell, :info, ["\nYour application is ready to be deployed" <> _]}
    end)
  end
end