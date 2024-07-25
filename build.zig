const std = @import("std");

pub fn build(b: *std.Build) void {
    // configure target-specific options for compiling
    const target = b.standardTargetOptions(.{});

    // related to optimization levels when compiling
    const optimize = b.standardOptimizeOption(.{ .preferred_optimize_mode = .ReleaseSafe});

    // define a new executable target
    const exe = b.addExecutable(.{
        .name = "TicTacToe",
        .root_source_file = b.path("src/main.zig"),
        .optimize = optimize,
        .target = target,
    });

    const raylib_zig = b.dependency("raylib-zig", .{
        .target = target, 
        .optimize = optimize,
    });

    const raylib = raylib_zig.module("raylib");
    const raylib_artifact = raylib_zig.artifact("raylib");

    // To link a library in your Zig build script (build.zig),
    exe.linkLibrary(raylib_artifact);

    // specify additional modules that should be included during the build process
        exe.root_module.addImport("raylib", raylib);

    // method used to handle the installation of built artifacts, 
    // such as executables or libraries, to specified locations
    b.installArtifact(exe);

    // specify an artifact (like an executable or library) 
    // that should be executed as part of the build process
    const run_cmd = b.addRunArtifact(exe);

    // ensures that one target is built before another
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        //  allows you to pass additional arguments to the compiler or linker when building your targets
        run_cmd.addArgs(args);
    }
    const run_step = b.step("run", "Run the executable");
    run_step.dependOn(&run_cmd.step);
}