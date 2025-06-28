const std = @import("std");

pub fn setupMacOSApp(b: *std.Build, lib: *std.Build.Step.Compile) void {
    // Define paths for the .app bundle
    const app_name = "x.app";
    const install_step = b.getInstallStep();
    const install_prefix = b.install_prefix; // This is typically zig-out

    const app_bundle_path = std.fs.path.join(b.allocator, &.{ install_prefix, app_name }) catch @panic("OOM");
    const macos_dir_path = std.fs.path.join(b.allocator, &.{ app_bundle_path, "Contents", "MacOS" }) catch @panic("OOM");
    const resources_dir_path = std.fs.path.join(b.allocator, &.{ app_bundle_path, "Contents", "Resources" }) catch @panic("OOM");
    const info_plist_dest_path = std.fs.path.join(b.allocator, &.{ app_bundle_path, "Contents", "Info.plist" }) catch @panic("OOM");
    const executable_dest_path = std.fs.path.join(b.allocator, &.{ macos_dir_path, "x" }) catch @panic("OOM");

    // 1. Create the .app bundle directory structure
    const create_dirs_run_step = std.Build.Step.Run.create(b, "create app bundle directories");
    create_dirs_run_step.addArgs(&.{
        "mkdir",            "-p", macos_dir_path,
        resources_dir_path,
    });

    // 2. Copy Info.plist into the .app bundle
    const copy_plist_run_step = std.Build.Step.Run.create(b, "copy Info.plist");
    copy_plist_run_step.addArgs(&.{
        "cp",
    });
    copy_plist_run_step.addFileArg(b.path("macos/Info.plist"));
    copy_plist_run_step.addArg(info_plist_dest_path);
    copy_plist_run_step.step.dependOn(&create_dirs_run_step.step); // Depend on directories being created

    // 3. Compile Swift code and link with Zig library
    const swift_compile_run_step = std.Build.Step.Run.create(b, "compile Swift and link Zig");
    swift_compile_run_step.addArgs(&.{
        "swiftc",
    });
    swift_compile_run_step.addFileArg(b.path("macos/main.swift"));
    swift_compile_run_step.addArgs(&.{
        "-import-objc-header", std.fs.path.join(b.allocator, &.{ install_prefix, "include", "x.h" }) catch @panic("OOM"),
        "-L",                  std.fs.path.join(b.allocator, &.{ install_prefix, "lib" }) catch @panic("OOM"),
        "-lx",
    });
    swift_compile_run_step.addArgs(&.{
        "-o", executable_dest_path,
    });
    swift_compile_run_step.step.dependOn(&lib.step); // Depend on Zig library being built
    swift_compile_run_step.step.dependOn(&copy_plist_run_step.step); // Depend on Info.plist being copied

    // Make the default 'install' step also build the app bundle
    install_step.dependOn(&swift_compile_run_step.step);

    // Add a 'run' step to open the .app bundle
    const run_app_step = b.step("run", "Run the macOS application bundle.");
    const run_app_run_step = std.Build.Step.Run.create(b, "open app bundle");
    run_app_run_step.addArgs(&.{
        "open", app_bundle_path,
    });
    run_app_run_step.step.dependOn(&swift_compile_run_step.step); // Ensure app is built before running
    run_app_step.dependOn(&run_app_run_step.step);
}