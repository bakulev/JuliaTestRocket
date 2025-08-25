using Documenter
using PointController

# Set up GLMakie for documentation builds
using GLMakie
GLMakie.activate!()

makedocs(;
    modules = [PointController],
    authors = "Bakulev <bakulev@users.noreply.github.com> and contributors",
    repo = "https://github.com/bakulev/JuliaTestRocket/blob/{commit}{path}#{line}",
    sitename = "JuliaTestRocket",
    format = Documenter.HTML(;
        prettyurls = get(ENV, "CI", "false") == "true",
        canonical = "https://bakulev.github.io/JuliaTestRocket",
        edit_link = "main",
        assets = String[],
        sidebar_sitename = false,
    ),
    pages = [
        "Home" => "index.md",
        "Getting Started" => "getting-started.md",
        "API Reference" => "api.md",
        "Examples" => "examples.md",
        "Troubleshooting" => "troubleshooting.md",
    ],
    checkdocs = :none,
    linkcheck = true,
)

deploydocs(;
    repo = "github.com/bakulev/JuliaTestRocket",
    devbranch = "main",
    push_preview = true,
)
