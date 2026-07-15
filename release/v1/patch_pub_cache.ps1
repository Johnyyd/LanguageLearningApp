# Script tu dong kiem tra va va loi tuong thich AGP 9 + Kotlin 2.0+ cho flutter_unity_widget trong Pub Cache (ASCII only to avoid PowerShell encoding bugs)
$ErrorActionPreference = "SilentlyContinue"

$unityWidgetDir = "$env:LOCALAPPDATA\Pub\Cache\hosted\pub.dev\flutter_unity_widget-2022.2.1\android"
if (Test-Path $unityWidgetDir) {
    # 1. Patch android/build.gradle
    $unityWidgetGradle = "$unityWidgetDir\build.gradle"
    if (Test-Path $unityWidgetGradle) {
        $content = Get-Content -Path $unityWidgetGradle -Raw
        $modified = $false

        if ($content -match "jcenter\(\)") {
            Write-Host "[INFO] Patching jcenter() -> mavenCentral() in build.gradle..." -ForegroundColor Yellow
            $content = $content -replace "jcenter\(\)", "mavenCentral()"
            $modified = $true
        }
        if ($content -notmatch "namespace") {
            Write-Host "[INFO] Adding namespace to build.gradle..." -ForegroundColor Yellow
            $content = $content -replace "android \{", "android {`r`n    namespace 'com.xraph.plugin.flutter_unity_widget'"
            $modified = $true
        }
        if ($content -notmatch "kotlinOptions") {
            Write-Host "[INFO] Adding kotlinOptions jvmTarget = 1.8 to build.gradle..." -ForegroundColor Yellow
            $content = $content -replace "targetCompatibility 1\.8", "targetCompatibility 1.8`r`n    }`r`n    kotlinOptions {`r`n        jvmTarget = '1.8'"
            $modified = $true
        }
        if ($content -match "implementation\(name: 'unity-classes', ext:'jar'\)" -or $content -match "api files\('libs/unity-classes\.jar'\)") {
            Write-Host "[INFO] Patching unity-classes dependency to compileOnly files('libs/unity-classes.jar')..." -ForegroundColor Yellow
            $content = $content -replace "implementation\(name: 'unity-classes', ext:'jar'\)", "compileOnly files('libs/unity-classes.jar')"
            $content = $content -replace "api files\('libs/unity-classes\.jar'\)", "compileOnly files('libs/unity-classes.jar')"
            $modified = $true
        }
        if ($modified) {
            Set-Content -Path $unityWidgetGradle -Value $content
            Write-Host "[SUCCESS] Patched flutter_unity_widget build.gradle!" -ForegroundColor Green
        }
    }

    # 2. Patch LifecycleProvider.kt
    $lpKt = "$unityWidgetDir\src\main\kotlin\com\xraph\plugin\flutter_unity_widget\LifecycleProvider.kt"
    if (Test-Path $lpKt) {
        $lpContent = Get-Content -Path $lpKt -Raw
        if ($lpContent -notmatch "interface LifecycleProvider : LifecycleOwner") {
            Write-Host "[INFO] Patching LifecycleProvider.kt to extend LifecycleOwner..." -ForegroundColor Yellow
            $newLp = "package com.xraph.plugin.flutter_unity_widget`r`n`r`nimport androidx.lifecycle.LifecycleOwner`r`n`r`ninterface LifecycleProvider : LifecycleOwner`r`n"
            Set-Content -Path $lpKt -Value $newLp
            Write-Host "[SUCCESS] Patched LifecycleProvider.kt!" -ForegroundColor Green
        }
    }

    # 3. Patch FlutterUnityWidgetPlugin.kt
    $pluginKt = "$unityWidgetDir\src\main\kotlin\com\xraph\plugin\flutter_unity_widget\FlutterUnityWidgetPlugin.kt"
    if (Test-Path $pluginKt) {
        $ktContent = Get-Content -Path $pluginKt -Raw
        $ktMod = $false
        if ($ktContent -match "override fun getLifecycle\(\): Lifecycle \{\s*return lifecycle!!\s*\}") {
            Write-Host "[INFO] Patching anonymous LifecycleProvider object in FlutterUnityWidgetPlugin.kt..." -ForegroundColor Yellow
            $ktContent = $ktContent -replace "override fun getLifecycle\(\): Lifecycle \{\s*return lifecycle!!\s*\}", "override val lifecycle: Lifecycle`r`n                                        get() = this@FlutterUnityWidgetPlugin.lifecycle!!"
            $ktMod = $true
        }
        if ($ktContent -match 'private val lifecycle = LifecycleRegistry\(this\)') {
            Write-Host "[INFO] Patching ProxyLifecycleProvider in FlutterUnityWidgetPlugin.kt for Kotlin 2.0+..." -ForegroundColor Yellow
            $ktContent = $ktContent -replace 'private val lifecycle = LifecycleRegistry\(this\)', "private val _lifecycle = LifecycleRegistry(this)`r`n        override val lifecycle: Lifecycle`r`n            get() = _lifecycle"
            $ktContent = $ktContent -replace 'lifecycle\.handleLifecycleEvent', '_lifecycle.handleLifecycleEvent'
            $ktContent = $ktContent -replace 'override fun getLifecycle\(\): Lifecycle \{\s*return lifecycle\s*\}', ""
            $ktContent = $ktContent -replace 'override fun getLifecycle\(\): Lifecycle \{\s*return _lifecycle\s*\}', ""
            $ktMod = $true
        }
        if ($ktMod) {
            Set-Content -Path $pluginKt -Value $ktContent
            Write-Host "[SUCCESS] Patched FlutterUnityWidgetPlugin.kt!" -ForegroundColor Green
        }
    }

    # 4. Patch FlutterUnityWidgetController.kt
    $ctrlKt = "$unityWidgetDir\src\main\kotlin\com\xraph\plugin\flutter_unity_widget\FlutterUnityWidgetController.kt"
    if (Test-Path $ctrlKt) {
        $ctrlContent = Get-Content -Path $ctrlKt -Raw
        $ctrlMod = $false
        if ($ctrlContent -match "lifecycleProvider\.getLifecycle\(\)") {
            Write-Host "[INFO] Patching lifecycleProvider.getLifecycle() calls in FlutterUnityWidgetController.kt..." -ForegroundColor Yellow
            $ctrlContent = $ctrlContent -replace "lifecycleProvider\.getLifecycle\(\)", "lifecycleProvider.lifecycle"
            $ctrlMod = $true
        }
        if ($ctrlMod) {
            Set-Content -Path $ctrlKt -Value $ctrlContent
            Write-Host "[SUCCESS] Patched FlutterUnityWidgetController.kt!" -ForegroundColor Green
        }
    }
}
