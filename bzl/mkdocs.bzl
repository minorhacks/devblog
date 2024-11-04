load("@bazel_skylib//lib:paths.bzl", "paths")

def _recurse_to_root_from(path):
    num_dirs = len(paths.dirname(path).split("/"))
    return "/".join([".."] * num_dirs) + "/"

def _mkdocs_site_impl(ctx):
    out_dir = ctx.actions.declare_directory(ctx.attr.name + "_gen")

    inputs = depset(direct = [ctx.file.config], transitive = [t.files for t in ctx.attr.srcs])

    args = ctx.actions.args()
    args.add("build")
    args.add("--site-dir", _recurse_to_root_from(ctx.file.config.path) + out_dir.path)
    args.add("--config-file", ctx.file.config.path)
    args.add("--verbose")

    ctx.actions.run(
        inputs = inputs,
        outputs = [out_dir],
        executable = ctx.executable._mkdocs_tool,
        arguments = [args],
        mnemonic = "MkdocsSiteGen",
        progress_message = "Generating Mkdocs site %{label}",
    )

    return [
        DefaultInfo(files = depset(direct = [out_dir])),
    ]

mkdocs_site = rule(
    implementation = _mkdocs_site_impl,
    attrs = {
        "srcs": attr.label_list(
            mandatory = True,
            allow_files = [".md"],
        ),
        "config": attr.label(
            mandatory = True,
            allow_single_file = ["yml"],
        ),
        "_mkdocs_tool": attr.label(
            default = "//:mkdocs",
            executable = True,
            cfg = "exec",
        ),
    },
)
