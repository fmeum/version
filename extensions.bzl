def _to_identifier(name):
    return name.replace("-", "_").replace(".", "_").upper()

def _version_bzl_repo_impl(repository_ctx):
    repository_ctx.file("WORKSPACE.bazel")
    repository_ctx.file("BUILD.bazel")
    lines = [
        "{identifier}_VERSION = {version}".format(
            identifier = _to_identifier(name),
            version = repr(version),
        )
        for name, version in repository_ctx.attr.versions.items()
    ]
    repository_ctx.file("version.bzl", "\n".join(sorted(lines)))

_version_bzl_repo = repository_rule(
    implementation = _version_bzl_repo_impl,
    attrs = {
        "versions": attr.string_dict(),
    },
)

_generate_tag = tag_class()

def _version_impl(module_ctx):
    _version_bzl_repo(
        name = "version_bzl",
        versions = {
            module.name: module.version
            for module in module_ctx.modules
        },
    )

version_bzl = module_extension(
    implementation = _version_impl,
    tag_classes = {
        "generate": _generate_tag,
    },
)
