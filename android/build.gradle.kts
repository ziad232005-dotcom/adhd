allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
// Some plugins (for example file_picker) are still compiled against an
// older Android API than their dependencies need. Compile every plugin
// against API 36 so the build passes. This must stay above the
// evaluationDependsOn block below.
subprojects {
    val raiseCompileSdk: Project.() -> Unit = {
        val android = extensions.findByName("android")
        if (android is com.android.build.api.dsl.LibraryExtension) {
            android.compileSdk = 36
        }
    }

    if (state.executed) {
        raiseCompileSdk()
    } else {
        afterEvaluate { raiseCompileSdk() }
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
