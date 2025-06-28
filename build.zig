const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Get the example to build from command line option
    const example = b.option([]const u8, "example", "Which example to build (swift-main or zig-main)");

    // Setup both examples
    const swift_main_step = setupSwiftMainExample(b, target, optimize);
    const zig_main_step = setupZigMainExample(b, target, optimize);

    // If a specific example is requested, make it the default
    if (example) |ex| {
        if (std.mem.eql(u8, ex, "swift-main")) {
            b.default_step.dependOn(swift_main_step);
        } else if (std.mem.eql(u8, ex, "zig-main")) {
            b.default_step.dependOn(zig_main_step);
        } else {
            std.debug.panic("Unknown example: {s}. Use 'swift-main' or 'zig-main'", .{ex});
        }
    } else {
        // Default to swift-main for backward compatibility
        b.default_step.dependOn(swift_main_step);
    }

    // Add a 'clean' step
    const clean_step = b.step("clean", "Remove build artifacts.");
    const clean_run_step = std.Build.Step.Run.create(b, "clean build artifacts");
    clean_run_step.addArgs(&.{
        "rm", "-rf", b.install_prefix, ".zig-cache",
    });
    clean_step.dependOn(&clean_run_step.step);
}

fn setupSwiftMainExample(b: *std.Build, target: std.Build.ResolvedTarget, optimize: std.builtin.OptimizeMode) *std.Build.Step {
    // Build the Zig static library
    const lib = b.addStaticLibrary(.{
        .name = "x_swift_main",
        .root_source_file = b.path("examples/swift-main/src/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    lib.installHeader(b.path("examples/swift-main/include/x.h"), "x.h");
    b.installArtifact(lib);

    // Define paths for the .app bundle
    const app_name = "swift-main.app";
    const install_prefix = b.install_prefix;

    const app_bundle_path = std.fs.path.join(b.allocator, &.{ install_prefix, app_name }) catch @panic("OOM");
    const macos_dir_path = std.fs.path.join(b.allocator, &.{ app_bundle_path, "Contents", "MacOS" }) catch @panic("OOM");
    const resources_dir_path = std.fs.path.join(b.allocator, &.{ app_bundle_path, "Contents", "Resources" }) catch @panic("OOM");
    const info_plist_dest_path = std.fs.path.join(b.allocator, &.{ app_bundle_path, "Contents", "Info.plist" }) catch @panic("OOM");
    const executable_dest_path = std.fs.path.join(b.allocator, &.{ macos_dir_path, "swift-main" }) catch @panic("OOM");

    // Create the .app bundle directory structure
    const create_dirs_run_step = std.Build.Step.Run.create(b, "create swift-main app bundle directories");
    create_dirs_run_step.addArgs(&.{
        "mkdir", "-p", macos_dir_path,
        resources_dir_path,
    });

    // Copy Info.plist into the .app bundle
    const copy_plist_run_step = std.Build.Step.Run.create(b, "copy swift-main Info.plist");
    copy_plist_run_step.addArgs(&.{ "cp" });
    copy_plist_run_step.addFileArg(b.path("examples/swift-main/macos/Info.plist"));
    copy_plist_run_step.addArg(info_plist_dest_path);
    copy_plist_run_step.step.dependOn(&create_dirs_run_step.step);

    // Compile Swift code and link with Zig library
    const swift_compile_run_step = std.Build.Step.Run.create(b, "compile Swift-main and link Zig");
    swift_compile_run_step.addArgs(&.{ "swiftc" });
    swift_compile_run_step.addFileArg(b.path("examples/swift-main/macos/main.swift"));
    swift_compile_run_step.addArgs(&.{
        "-import-objc-header", std.fs.path.join(b.allocator, &.{ install_prefix, "include", "x.h" }) catch @panic("OOM"),
        "-L",                  std.fs.path.join(b.allocator, &.{ install_prefix, "lib" }) catch @panic("OOM"),
        "-lx_swift_main",
        "-o", executable_dest_path,
    });
    swift_compile_run_step.step.dependOn(&lib.step);
    swift_compile_run_step.step.dependOn(&copy_plist_run_step.step);

    // Create build step
    const swift_main_step = b.step("swift-main", "Build Swift-as-main example");
    swift_main_step.dependOn(&swift_compile_run_step.step);

    // Add run step
    const run_swift_main_step = b.step("run-swift-main", "Run the Swift-as-main macOS application");
    const run_swift_main_run_step = std.Build.Step.Run.create(b, "open swift-main app bundle");
    run_swift_main_run_step.addArgs(&.{ "open", app_bundle_path });
    run_swift_main_run_step.step.dependOn(&swift_compile_run_step.step);
    run_swift_main_step.dependOn(&run_swift_main_run_step.step);

    // Add run alias for consistency
    const run_step = b.step("run", "Run the default (Swift-as-main) macOS application");
    run_step.dependOn(run_swift_main_step);

    return &swift_compile_run_step.step;
}

fn setupZigMainExample(b: *std.Build, target: std.Build.ResolvedTarget, optimize: std.builtin.OptimizeMode) *std.Build.Step {
    // Define paths for the .app bundle
    const app_name = "zig-main.app";
    const install_prefix = b.install_prefix;

    const app_bundle_path = std.fs.path.join(b.allocator, &.{ install_prefix, app_name }) catch @panic("OOM");
    const macos_dir_path = std.fs.path.join(b.allocator, &.{ app_bundle_path, "Contents", "MacOS" }) catch @panic("OOM");
    const resources_dir_path = std.fs.path.join(b.allocator, &.{ app_bundle_path, "Contents", "Resources" }) catch @panic("OOM");
    const info_plist_dest_path = std.fs.path.join(b.allocator, &.{ app_bundle_path, "Contents", "Info.plist" }) catch @panic("OOM");
    const executable_dest_path = std.fs.path.join(b.allocator, &.{ macos_dir_path, "zig-main" }) catch @panic("OOM");

    // Create the .app bundle directory structure
    const create_dirs_run_step = std.Build.Step.Run.create(b, "create zig-main app bundle directories");
    create_dirs_run_step.addArgs(&.{
        "mkdir", "-p", macos_dir_path,
        resources_dir_path,
    });

    // Copy Info.plist into the .app bundle
    const copy_plist_run_step = std.Build.Step.Run.create(b, "copy zig-main Info.plist");
    copy_plist_run_step.addArgs(&.{ "cp" });
    copy_plist_run_step.addFileArg(b.path("examples/zig-main/macos/Info.plist"));
    copy_plist_run_step.addArg(info_plist_dest_path);
    copy_plist_run_step.step.dependOn(&create_dirs_run_step.step);

    // Build the Zig object file
    const obj = b.addObject(.{
        .name = "zig-main",
        .root_source_file = b.path("examples/zig-main/src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    // Compile everything together with swiftc
    const compile_all_step = std.Build.Step.Run.create(b, "compile Zig and Swift together");
    compile_all_step.addArgs(&.{ "swiftc", "-parse-as-library" });
    compile_all_step.addFileArg(b.path("examples/zig-main/macos/ui.swift"));
    compile_all_step.addFileArg(obj.getEmittedBin());
    compile_all_step.addArgs(&.{
        "-o", executable_dest_path,
    });
    compile_all_step.step.dependOn(&obj.step);
    compile_all_step.step.dependOn(&copy_plist_run_step.step);

    // Create build step
    const zig_main_step = b.step("zig-main", "Build Zig-as-main example");
    zig_main_step.dependOn(&compile_all_step.step);

    // Add run step
    const run_zig_main_step = b.step("run-zig-main", "Run the Zig-as-main macOS application");
    const run_zig_main_run_step = std.Build.Step.Run.create(b, "open zig-main app bundle");
    run_zig_main_run_step.addArgs(&.{ "open", app_bundle_path });
    run_zig_main_run_step.step.dependOn(&compile_all_step.step);
    run_zig_main_step.dependOn(&run_zig_main_run_step.step);

    return &compile_all_step.step;
}