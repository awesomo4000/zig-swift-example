const std = @import("std");

// Structure to hold app bundle paths
const AppBundle = struct {
    app_path: []const u8,
    macos_dir: []const u8,
    resources_dir: []const u8,
    info_plist_dest: []const u8,
    executable_dest: []const u8,
};

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Get the example to build from command line option
    const example = b.option([]const u8, "example", "Which example to build (swift-main, swiftui-main, zig-main, or zig-swiftui)");

    // Setup all examples
    const swift_main_step = setupSwiftMainExample(b, target, optimize);
    const swiftui_main_step = setupSwiftUIMainExample(b, target, optimize);
    const zig_main_step = setupZigMainExample(b, target, optimize);
    const zig_swiftui_step = setupZigSwiftUIExample(b, target, optimize);

    // If a specific example is requested, make it the default
    if (example) |ex| {
        if (std.mem.eql(u8, ex, "swift-main")) {
            b.default_step.dependOn(swift_main_step);
        } else if (std.mem.eql(u8, ex, "swiftui-main")) {
            b.default_step.dependOn(swiftui_main_step);
        } else if (std.mem.eql(u8, ex, "zig-main")) {
            b.default_step.dependOn(zig_main_step);
        } else if (std.mem.eql(u8, ex, "zig-swiftui")) {
            b.default_step.dependOn(zig_swiftui_step);
        } else {
            std.debug.panic("Unknown example: {s}. Use 'swift-main', 'swiftui-main', 'zig-main', or 'zig-swiftui'", .{ex});
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

// Helper function to create app bundle structure
fn createAppBundle(b: *std.Build, app_name: []const u8, example_name: []const u8) AppBundle {
    const install_prefix = b.install_prefix;
    const app_bundle_path = std.fs.path.join(b.allocator, &.{ install_prefix, app_name }) catch @panic("OOM");
    const macos_dir_path = std.fs.path.join(b.allocator, &.{ app_bundle_path, "Contents", "MacOS" }) catch @panic("OOM");
    const resources_dir_path = std.fs.path.join(b.allocator, &.{ app_bundle_path, "Contents", "Resources" }) catch @panic("OOM");
    const info_plist_dest_path = std.fs.path.join(b.allocator, &.{ app_bundle_path, "Contents", "Info.plist" }) catch @panic("OOM");
    const executable_dest_path = std.fs.path.join(b.allocator, &.{ macos_dir_path, example_name }) catch @panic("OOM");

    return AppBundle{
        .app_path = app_bundle_path,
        .macos_dir = macos_dir_path,
        .resources_dir = resources_dir_path,
        .info_plist_dest = info_plist_dest_path,
        .executable_dest = executable_dest_path,
    };
}

// Helper function to create app bundle directories and copy Info.plist
fn setupAppBundleStructure(b: *std.Build, bundle: AppBundle, info_plist_src: []const u8, description: []const u8) *std.Build.Step {
    // Create the .app bundle directory structure
    const create_dirs_run_step = std.Build.Step.Run.create(b, b.fmt("create {s} app bundle directories", .{description}));
    create_dirs_run_step.addArgs(&.{
        "mkdir", "-p", bundle.macos_dir,
        bundle.resources_dir,
    });

    // Copy Info.plist into the .app bundle
    const copy_plist_run_step = std.Build.Step.Run.create(b, b.fmt("copy {s} Info.plist", .{description}));
    copy_plist_run_step.addArgs(&.{ "cp" });
    copy_plist_run_step.addFileArg(b.path(info_plist_src));
    copy_plist_run_step.addArg(bundle.info_plist_dest);
    copy_plist_run_step.step.dependOn(&create_dirs_run_step.step);

    return &copy_plist_run_step.step;
}

// Helper function to create run step for app bundle
fn createRunStep(b: *std.Build, step_name: []const u8, step_description: []const u8, app_bundle_path: []const u8, depends_on: *std.Build.Step) *std.Build.Step {
    const run_step = b.step(step_name, step_description);
    const run_run_step = std.Build.Step.Run.create(b, b.fmt("open {s}", .{step_name}));
    run_run_step.addArgs(&.{ "open", app_bundle_path });
    run_run_step.step.dependOn(depends_on);
    run_step.dependOn(&run_run_step.step);
    return run_step;
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

    // Create app bundle structure
    const bundle = createAppBundle(b, "swift-main.app", "swift-main");
    const bundle_setup = setupAppBundleStructure(b, bundle, "examples/swift-main/macos/Info.plist", "swift-main");

    // Compile Swift code and link with Zig library
    const swift_compile_run_step = std.Build.Step.Run.create(b, "compile Swift-main and link Zig");
    swift_compile_run_step.addArgs(&.{ "swiftc" });
    swift_compile_run_step.addFileArg(b.path("examples/swift-main/macos/main.swift"));
    swift_compile_run_step.addArgs(&.{
        "-import-objc-header", std.fs.path.join(b.allocator, &.{ b.install_prefix, "include", "x.h" }) catch @panic("OOM"),
        "-L",                  std.fs.path.join(b.allocator, &.{ b.install_prefix, "lib" }) catch @panic("OOM"),
        "-lx_swift_main",
        "-o", bundle.executable_dest,
    });
    swift_compile_run_step.step.dependOn(&lib.step);
    swift_compile_run_step.step.dependOn(bundle_setup);

    // Create build step
    const swift_main_step = b.step("swift-main", "Build Swift-as-main example");
    swift_main_step.dependOn(&swift_compile_run_step.step);

    // Add run step
    const run_swift_main_step = createRunStep(b, "run-swift-main", "Run the Swift-as-main macOS application", bundle.app_path, &swift_compile_run_step.step);

    // Add run alias for consistency
    const run_step = b.step("run", "Run the default (Swift-as-main) macOS application");
    run_step.dependOn(run_swift_main_step);

    return &swift_compile_run_step.step;
}

fn setupSwiftUIMainExample(b: *std.Build, target: std.Build.ResolvedTarget, optimize: std.builtin.OptimizeMode) *std.Build.Step {
    // Build the Zig static library
    const lib = b.addStaticLibrary(.{
        .name = "x_swiftui_main",
        .root_source_file = b.path("examples/swiftui-main/src/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    lib.installHeader(b.path("examples/swiftui-main/include/x.h"), "x.h");
    b.installArtifact(lib);

    // Create app bundle structure
    const bundle = createAppBundle(b, "swiftui-main.app", "swiftui-main");
    const bundle_setup = setupAppBundleStructure(b, bundle, "examples/swiftui-main/macos/Info.plist", "swiftui-main");

    // Compile Swift code and link with Zig library
    const swift_compile_run_step = std.Build.Step.Run.create(b, "compile SwiftUI-main and link Zig");
    swift_compile_run_step.addArgs(&.{ "swiftc", "-parse-as-library" });
    swift_compile_run_step.addFileArg(b.path("examples/swiftui-main/macos/main.swift"));
    swift_compile_run_step.addArgs(&.{
        "-import-objc-header", std.fs.path.join(b.allocator, &.{ b.install_prefix, "include", "x.h" }) catch @panic("OOM"),
        "-L",                  std.fs.path.join(b.allocator, &.{ b.install_prefix, "lib" }) catch @panic("OOM"),
        "-lx_swiftui_main",
        "-o", bundle.executable_dest,
    });
    swift_compile_run_step.step.dependOn(&lib.step);
    swift_compile_run_step.step.dependOn(bundle_setup);

    // Create build step
    const swiftui_main_step = b.step("swiftui-main", "Build SwiftUI-as-main example");
    swiftui_main_step.dependOn(&swift_compile_run_step.step);

    // Add run step
    _ = createRunStep(b, "run-swiftui-main", "Run the SwiftUI-as-main macOS application", bundle.app_path, &swift_compile_run_step.step);

    return &swift_compile_run_step.step;
}

fn setupZigMainExample(b: *std.Build, target: std.Build.ResolvedTarget, optimize: std.builtin.OptimizeMode) *std.Build.Step {
    // Create app bundle structure
    const bundle = createAppBundle(b, "zig-main.app", "zig-main");
    const bundle_setup = setupAppBundleStructure(b, bundle, "examples/zig-main/macos/Info.plist", "zig-main");

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
        "-o", bundle.executable_dest,
    });
    compile_all_step.step.dependOn(&obj.step);
    compile_all_step.step.dependOn(bundle_setup);

    // Create build step
    const zig_main_step = b.step("zig-main", "Build Zig-as-main example");
    zig_main_step.dependOn(&compile_all_step.step);

    // Add run step
    _ = createRunStep(b, "run-zig-main", "Run the Zig-as-main macOS application", bundle.app_path, &compile_all_step.step);

    return &compile_all_step.step;
}

fn setupZigSwiftUIExample(b: *std.Build, target: std.Build.ResolvedTarget, optimize: std.builtin.OptimizeMode) *std.Build.Step {
    // Create app bundle structure
    const bundle = createAppBundle(b, "zig-swiftui.app", "zig-swiftui");
    const bundle_setup = setupAppBundleStructure(b, bundle, "examples/zig-swiftui/macos/Info.plist", "zig-swiftui");

    // Build the Zig object file
    const obj = b.addObject(.{
        .name = "zig-swiftui",
        .root_source_file = b.path("examples/zig-swiftui/src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    // Compile everything together with swiftc
    const compile_all_step = std.Build.Step.Run.create(b, "compile Zig and SwiftUI together");
    compile_all_step.addArgs(&.{ "swiftc", "-parse-as-library" });
    compile_all_step.addFileArg(b.path("examples/zig-swiftui/macos/ui.swift"));
    compile_all_step.addFileArg(obj.getEmittedBin());
    compile_all_step.addArgs(&.{
        "-o", bundle.executable_dest,
    });
    compile_all_step.step.dependOn(&obj.step);
    compile_all_step.step.dependOn(bundle_setup);

    // Create build step
    const zig_swiftui_step = b.step("zig-swiftui", "Build Zig-as-main with SwiftUI example");
    zig_swiftui_step.dependOn(&compile_all_step.step);

    // Add run step
    _ = createRunStep(b, "run-zig-swiftui", "Run the Zig-as-main SwiftUI application", bundle.app_path, &compile_all_step.step);

    return &compile_all_step.step;
}