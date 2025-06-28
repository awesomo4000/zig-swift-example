const std = @import("std");
const macos = @import("build/macos.zig");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Compile the Zig static library
    const lib = b.addStaticLibrary(.{
        .name = "x",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    // Install the C header for Swift to use
    lib.installHeader(b.path("include/x.h"), "x.h");
    b.installArtifact(lib); // This installs libx.a to zig-out/lib

    // Setup macOS app bundle
    macos.setupMacOSApp(b, lib);

    // Add a 'clean' step
    const clean_step = b.step("clean", "Remove build artifacts.");
    const clean_run_step = std.Build.Step.Run.create(b, "clean build artifacts");
    clean_run_step.addArgs(&.{
        "rm", "-rf", b.install_prefix, ".zig-cache",
    });
    clean_step.dependOn(&clean_run_step.step);
}
