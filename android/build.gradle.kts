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
    if (project.name == "flutter_angle") {
        val bg = project.file("build.gradle")
        if (bg.exists()) {
            val content = bg.readText()
            if (content.contains("3.31.4")) {
                bg.writeText(content.replace("3.31.4", "3.22.1"))
            }
        }
        val cm = project.file("src/main/cpp/CMakeLists.txt")
        if (cm.exists()) {
            val cmContent = cm.readText()
            if (cmContent.contains("3.31.4")) {
                cm.writeText(cmContent.replace("3.31.4", "3.18.1"))
            }
        }
    }
}
subprojects {
    project.evaluationDependsOn(":app")
}

subprojects {
    tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile>().configureEach {
        if (project.name == "tflite_flutter") {
            compilerOptions {
                jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_11)
            }
        } else if (project.name == "screen_protector") {
            compilerOptions {
                jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
