defmodule LettuceTest do
  use ExUnit.Case

  doctest Lettuce.Config

  @ebin_path "_build/test/lib/{{project}}/ebin/"
  @compiled_file_pattern "Elixir.{{Project}}.{{module_file}}.beam"
  @fixture_projects ["recompile"]

  setup_all do
    files_mtime =
      @fixture_projects
      |> Enum.map(fn project ->
        project
        |> fixtures_full_path
        |> File.mkdir_p!()

        beam_file = beam_file(project, "ModuleFile", "test/fixtures/#{project}/")
        File.touch!(beam_file)
        {"#{beam_file}", modification_time(beam_file)}
      end)
      |> Enum.into(%{})

    on_exit(fn ->
      @fixture_projects
      |> Enum.each(fn project ->
        "test/fixtures/{{project}}/_build"
        |> String.replace("{{project}}", project)
        |> File.rm_rf!()
      end)
    end)

    %{files_mtime: files_mtime}
  end

  test "recompiles the project if a file is touched", %{files_mtime: files_mtime} do
    compiled_file = beam_file("Recompile", "ModuleFile")
    touch_in_project(files_mtime, "recompile", compiled_file)
  end

  test "does notihing if non file is touched" do
    compiled_file = beam_file("Recompile", "ModuleFile")

    Mix.Project.in_project(:project, "test/fixtures/recompile", fn _module ->
      init_mod_time = modification_time(compiled_file)

      assert init_mod_time == modification_time(compiled_file)
    end)
  end

  defp beam_file(project, module_file, prepend \\ "") do
    prepend
    |> Kernel.<>(@ebin_path)
    |> Kernel.<>(@compiled_file_pattern)
    |> String.replace("{{Project}}", project)
    |> String.replace("{{project}}", String.downcase(project))
    |> String.replace("{{module_file}}", module_file)
  end

  defp modification_time(path) do
    path
    |> File.lstat!()
    |> Map.get(:mtime)
  end

  defp fixtures_full_path(project) do
    fixtures_path = "test/fixtures/{{project}}/#{@ebin_path}"
    String.replace(fixtures_path, "{{project}}", project)
  end

  defp touch_in_project(initial_times, project, beam_file) do
    project
    |> String.to_existing_atom()
    |> Mix.Project.in_project("test/fixtures/#{project}", fn module ->
      IO.puts("Project: #{project} \n Module: #{module}")

      Process.sleep(2000)
      File.touch!("lib/module_file.ex")

      assert Map.get(initial_times, "#{beam_file}") != modification_time(beam_file)
    end)
  end
end
