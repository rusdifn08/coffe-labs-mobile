import 'dart:math' as math;
import 'dart:typed_data';

import 'package:three_js_core/three_js_core.dart' as three;
import 'package:three_js_curves/three_js_curves.dart' as curves;
import 'package:three_js_geometry/three_js_geometry.dart' as geom;
import 'package:three_js_math/three_js_math.dart' as tmath;

import 'gyro_kettle_physics_engine.dart';
import 'v60_3d_scene_renderer.dart';
import 'v60_bed_heightfield_solver.dart';

/// Pembangun & pembaru adegan 3D PBR nyata berbasis OpenGL ES / ANGLE (`three_js`):
/// Ketel Leher Angsa Fellow Stagg, Dripper Keramik Hario V60 bersiral rib, Kertas Filter
/// yang berubah basah, Glass Range Server yang dapat dimiringkan, Heightfield Ampas Kopi,
/// serta Pancaran Air Balistik 3D parabolik yang tersinkronisasi 1:1 dengan sensor HP.
class V60ThreeJsSceneBuilder {
  late final three.Group rootGroup;
  late final three.Group serverGroup;
  late final three.Group dripperGroup;
  late final three.Group kettleGroup;

  late final three.Mesh _serverLiquidMesh;
  late final three.Mesh _serverMeniscusMesh;
  late final three.Mesh _discardPourStreamMesh;

  late final three.Mesh _dripperConeMesh;
  late final three.MeshPhysicalMaterial _dripperMat;

  late final three.Mesh _paperFilterMesh;
  late final three.MeshStandardMaterial _paperMat;

  late final three.Mesh _coffeeBedMesh;
  late final three.BufferGeometry _bedGeo;
  static const int _bedGridN = 24;
  final List<_BedVertexInfo> _bedVertices = [];

  late final three.Mesh _slurryWaterMesh;
  late final three.MeshPhysicalMaterial _slurryMat;

  late final three.Mesh _kettleSpoutWaterMesh;
  late final three.BufferGeometry _streamGeo;
  late final three.Mesh _waterStreamMesh;
  late final three.MeshStandardMaterial _streamMat;

  late final three.Mesh _splashRingMesh;
  late final three.MeshStandardMaterial _splashMat;
  late final three.Mesh _targetRingMesh;
  late final three.MeshStandardMaterial _targetMat;

  late final three.Mesh _scaleLedBar;
  late final three.MeshStandardMaterial _scaleLedMat;

  final List<three.Mesh> _dropletMeshes = [];
  final List<three.Mesh> _steamMeshes = [];

  final tmath.Vector3 _spoutTipLocal = tmath.Vector3(-0.98, 0.50, 0.0);

  static const int _streamSegments = 16;
  static const int _streamRadial = 8;

  void buildIntoScene(three.Scene scene) {
    rootGroup = three.Group();
    scene.add(rootGroup);

    _setupLighting(scene);
    _buildEspressoTableAndScale();
    _buildGlassServer();
    _buildV60CeramicDripper();
    _buildPaperFilter();
    _buildCoffeeBedAndSlurry();
    _buildGooseneckKettle();
    _buildDynamicWaterStream();
    _buildDropsAndSteamPools();
  }

  void _setupLighting(three.Scene scene) {
    scene.add(three.AmbientLight(0xFFF3E2, 0.72));
    scene.add(three.HemisphereLight(0xFFF6E8, 0x26160D, 0.85));

    final keyLight = three.DirectionalLight(0xFFF7E6, 1.45);
    keyLight.position.setValues(3.4, 5.2, 3.6);
    keyLight.castShadow = true;
    keyLight.shadow?.mapSize.width = 1024;
    keyLight.shadow?.mapSize.height = 1024;
    scene.add(keyLight);

    final rimLight = three.DirectionalLight(0xFFD6A0, 0.75);
    rimLight.position.setValues(-3.2, 2.8, -2.8);
    scene.add(rimLight);

    final warmLamp = three.PointLight(0xFFE0B2, 0.9, 12.0);
    warmLamp.position.setValues(1.4, 2.8, 1.8);
    scene.add(warmLamp);
  }

  void _buildEspressoTableAndScale() {
    final woodMat = three.MeshStandardMaterial({
      three.MaterialProperty.color: 0x2B1A11,
      three.MaterialProperty.roughness: 0.70,
      three.MaterialProperty.metalness: 0.06,
    });
    final table = three.Mesh(three.BoxGeometry(5.6, 0.16, 4.8), woodMat);
    table.position.setValues(0, -1.33, 0);
    table.receiveShadow = true;
    rootGroup.add(table);

    // Timbangan digital barista bergaya Acaia Lunar Matte Black
    final scaleBodyMat = three.MeshStandardMaterial({
      three.MaterialProperty.color: 0x161920,
      three.MaterialProperty.metalness: 0.55,
      three.MaterialProperty.roughness: 0.34,
    });
    final scaleBase = three.Mesh(three.BoxGeometry(1.56, 0.11, 1.72), scaleBodyMat);
    scaleBase.position.setValues(0, -1.195, 0.04);
    scaleBase.castShadow = true;
    scaleBase.receiveShadow = true;
    rootGroup.add(scaleBase);

    // Bantalan karet tahan panas di atas timbangan
    final padMat = three.MeshStandardMaterial({
      three.MaterialProperty.color: 0x101216,
      three.MaterialProperty.roughness: 0.85,
      three.MaterialProperty.metalness: 0.05,
    });
    final pad = three.Mesh(geom.CylinderGeometry(0.66, 0.68, 0.025, 36), padMat);
    pad.position.setValues(0, -1.13, 0);
    pad.receiveShadow = true;
    rootGroup.add(pad);

    // Lampu LED indikator status timbangan di tepi depan
    _scaleLedMat = three.MeshStandardMaterial({
      three.MaterialProperty.color: 0x22C55E,
      three.MaterialProperty.emissive: tmath.Color.fromHex32(0x16A34A),
      three.MaterialProperty.roughness: 0.25,
    });
    _scaleLedBar = three.Mesh(three.BoxGeometry(0.62, 0.022, 0.03), _scaleLedMat);
    _scaleLedBar.position.setValues(0, -1.19, 0.90);
    rootGroup.add(_scaleLedBar);
  }

  void _buildGlassServer() {
    serverGroup = three.Group();
    serverGroup.position.setValues(0, -1.12, 0);
    rootGroup.add(serverGroup);

    final glassMat = three.MeshPhysicalMaterial({
      three.MaterialProperty.color: 0xDFF2FD,
      three.MaterialProperty.transparent: true,
      three.MaterialProperty.opacity: 0.29,
      three.MaterialProperty.roughness: 0.06,
      three.MaterialProperty.metalness: 0.04,
      three.MaterialProperty.clearcoat: 1.0,
      three.MaterialProperty.clearcoatRoughness: 0.05,
      three.MaterialProperty.depthWrite: false,
      three.MaterialProperty.side: tmath.DoubleSide,
    });

    final profile = <tmath.Vector2>[
      tmath.Vector2(0.01, 0.0),
      tmath.Vector2(0.60, 0.0),
      tmath.Vector2(0.67, 0.16),
      tmath.Vector2(0.63, 0.44),
      tmath.Vector2(0.42, 0.80),
      tmath.Vector2(0.38, 0.92),
      tmath.Vector2(0.45, 0.99),
    ];
    final carafe = three.Mesh(geom.LatheGeometry(profile, segments: 40), glassMat);
    carafe.castShadow = true;
    serverGroup.add(carafe);

    // Handle kaca di sebelah kanan teko server
    final handleCurve = curves.CubicBezierCurve3(
      tmath.Vector3(0.42, 0.86, 0),
      tmath.Vector3(0.86, 0.84, 0),
      tmath.Vector3(0.92, 0.24, 0),
      tmath.Vector3(0.62, 0.14, 0),
    );
    final handle = three.Mesh(
      geom.TubeGeometry(handleCurve, 22, 0.042, 10, false),
      glassMat,
    );
    serverGroup.add(handle);

    // Cincin karet collar di leher server
    final collarMat = three.MeshStandardMaterial({
      three.MaterialProperty.color: 0x1E2228,
      three.MaterialProperty.roughness: 0.68,
    });
    final collar = three.Mesh(geom.TorusGeometry(0.40, 0.024, 12, 36), collarMat);
    collar.rotation.x = math.pi / 2;
    collar.position.setValues(0, 0.88, 0);
    serverGroup.add(collar);

    // Cairan air bilasan / kopi amber di dalam glass server
    final liqMat = three.MeshStandardMaterial({
      three.MaterialProperty.color: 0x7C2D12,
      three.MaterialProperty.transparent: true,
      three.MaterialProperty.opacity: 0.86,
      three.MaterialProperty.roughness: 0.18,
    });
    _serverLiquidMesh = three.Mesh(
      geom.CylinderGeometry(0.48, 0.61, 0.64, 34),
      liqMat,
    );
    _serverLiquidMesh.position.setValues(0, 0.03, 0);
    _serverLiquidMesh.visible = false;
    serverGroup.add(_serverLiquidMesh);

    final meniscusMat = three.MeshStandardMaterial({
      three.MaterialProperty.color: 0xB45309,
      three.MaterialProperty.transparent: true,
      three.MaterialProperty.opacity: 0.90,
      three.MaterialProperty.roughness: 0.12,
    });
    _serverMeniscusMesh = three.Mesh(
      geom.CylinderGeometry(0.48, 0.48, 0.015, 34),
      meniscusMat,
    );
    _serverMeniscusMesh.visible = false;
    serverGroup.add(_serverMeniscusMesh);

    // Aliran buang air bilasan dari bibir teko saat server miring
    final discardCurve = curves.CubicBezierCurve3(
      tmath.Vector3(0.44, 0.96, 0),
      tmath.Vector3(0.78, 0.84, 0),
      tmath.Vector3(1.12, 0.25, 0),
      tmath.Vector3(1.26, -0.45, 0),
    );
    _discardPourStreamMesh = three.Mesh(
      geom.TubeGeometry(discardCurve, 14, 0.025, 8, false),
      three.MeshStandardMaterial({
        three.MaterialProperty.color: 0xBAE6FD,
        three.MaterialProperty.transparent: true,
        three.MaterialProperty.opacity: 0.72,
        three.MaterialProperty.roughness: 0.10,
      }),
    );
    _discardPourStreamMesh.visible = false;
    serverGroup.add(_discardPourStreamMesh);
  }

  void _buildV60CeramicDripper() {
    dripperGroup = three.Group();
    dripperGroup.position.setValues(0, -0.14, 0);
    rootGroup.add(dripperGroup);

    _dripperMat = three.MeshPhysicalMaterial({
      three.MaterialProperty.color: 0xFAF5EB,
      three.MaterialProperty.roughness: 0.14,
      three.MaterialProperty.metalness: 0.04,
      three.MaterialProperty.clearcoat: 0.95,
      three.MaterialProperty.clearcoatRoughness: 0.08,
      three.MaterialProperty.side: tmath.DoubleSide,
    });

    // Dudukan base piringan keramik V60
    final basePlate = three.Mesh(geom.CylinderGeometry(0.55, 0.57, 0.048, 40), _dripperMat);
    basePlate.position.setValues(0, 0.02, 0);
    basePlate.castShadow = true;
    basePlate.receiveShadow = true;
    dripperGroup.add(basePlate);

    final bottomRim = three.Mesh(geom.CylinderGeometry(0.24, 0.22, 0.09, 32), _dripperMat);
    bottomRim.position.setValues(0, -0.04, 0);
    dripperGroup.add(bottomRim);

    // Dinding kerucut V60 60 derajat (profil lathe berdinding ganda halus)
    final coneProfile = <tmath.Vector2>[
      tmath.Vector2(0.17, 0.02),
      tmath.Vector2(0.75, 0.80),
      tmath.Vector2(0.785, 0.81),
      tmath.Vector2(0.80, 0.78),
      tmath.Vector2(0.21, 0.02),
    ];
    _dripperConeMesh = three.Mesh(
      geom.LatheGeometry(coneProfile, segments: 42),
      _dripperMat,
    );
    _dripperConeMesh.castShadow = true;
    _dripperConeMesh.receiveShadow = true;
    dripperGroup.add(_dripperConeMesh);

    // 12 Rusuk Spiral Ikonik di bagian dalam Hario V60
    final ribMat = three.MeshPhysicalMaterial({
      three.MaterialProperty.color: 0xFFFDF8,
      three.MaterialProperty.roughness: 0.12,
      three.MaterialProperty.clearcoat: 1.0,
    });
    for (int i = 0; i < 12; i++) {
      final double baseAngle = i * math.pi * 2 / 12;
      final pts = <tmath.Vector3>[];
      for (int s = 0; s <= 6; s++) {
        final t = s / 6.0;
        final r = 0.18 + t * 0.545;
        final y = 0.06 + t * 0.70;
        final a = baseAngle + t * 0.72;
        pts.add(tmath.Vector3(math.cos(a) * r, y, math.sin(a) * r));
      }
      final ribMesh = three.Mesh(
        geom.TubeGeometry(curves.CatmullRomCurve3(points: pts), 12, 0.011, 6, false),
        ribMat,
      );
      dripperGroup.add(ribMesh);
    }

    // Handle keramik di sisi kiri untuk interaksi "Angkat Dripper"
    final handleCurve = curves.CubicBezierCurve3(
      tmath.Vector3(-0.62, 0.62, 0),
      tmath.Vector3(-1.02, 0.66, 0),
      tmath.Vector3(-1.02, 0.14, 0),
      tmath.Vector3(-0.38, 0.10, 0),
    );
    final ceramicHandle = three.Mesh(
      geom.TubeGeometry(handleCurve, 22, 0.044, 10, false),
      _dripperMat,
    );
    ceramicHandle.castShadow = true;
    dripperGroup.add(ceramicHandle);
  }

  void _buildPaperFilter() {
    _paperMat = three.MeshStandardMaterial({
      three.MaterialProperty.color: 0xF3EBDD,
      three.MaterialProperty.roughness: 0.92,
      three.MaterialProperty.metalness: 0.0,
      three.MaterialProperty.transparent: true,
      three.MaterialProperty.opacity: 0.94,
      three.MaterialProperty.side: tmath.DoubleSide,
    });
    final paperProfile = <tmath.Vector2>[
      tmath.Vector2(0.02, 0.01),
      tmath.Vector2(0.155, 0.04),
      tmath.Vector2(0.73, 0.80),
      tmath.Vector2(0.765, 0.855),
    ];
    _paperFilterMesh = three.Mesh(
      geom.LatheGeometry(paperProfile, segments: 36),
      _paperMat,
    );
    _paperFilterMesh.receiveShadow = true;
    dripperGroup.add(_paperFilterMesh);
  }

  void _buildCoffeeBedAndSlurry() {
    _bedGeo = three.BufferGeometry();
    final List<double> posList = [];
    final List<double> colList = [];
    final List<int> indices = [];
    final List<List<int>> gridIdx = List.generate(
      _bedGridN,
      (_) => List<int>.filled(_bedGridN, -1),
    );

    int vCursor = 0;
    for (int y = 0; y < _bedGridN; y++) {
      for (int x = 0; x < _bedGridN; x++) {
        final double nx = (x / (_bedGridN - 1)) * 2.0 - 1.0;
        final double nz = (y / (_bedGridN - 1)) * 2.0 - 1.0;
        final double r = math.sqrt(nx * nx + nz * nz);
        if (r <= 1.06) {
          gridIdx[y][x] = vCursor++;
          const double bedRadius = 0.50;
          posList.addAll([nx * bedRadius, 0.42, nz * bedRadius]);
          colList.addAll([0.42, 0.23, 0.12]);
          _bedVertices.add(_BedVertexInfo(nx, nz));
        }
      }
    }

    for (int y = 0; y < _bedGridN - 1; y++) {
      for (int x = 0; x < _bedGridN - 1; x++) {
        final a = gridIdx[y][x];
        final b = gridIdx[y][x + 1];
        final c = gridIdx[y + 1][x + 1];
        final d = gridIdx[y + 1][x];
        if (a >= 0 && b >= 0 && d >= 0) {
          indices.addAll([a, d, b]);
        }
        if (b >= 0 && c >= 0 && d >= 0) {
          indices.addAll([b, d, c]);
        }
      }
    }

    _bedGeo.setIndex(indices);
    _bedGeo.setAttributeFromString(
      'position',
      tmath.Float32BufferAttribute.fromList(posList, 3, false),
    );
    _bedGeo.setAttributeFromString(
      'color',
      tmath.Float32BufferAttribute.fromList(colList, 3, false),
    );
    _bedGeo.computeVertexNormals();

    final bedMat = three.MeshStandardMaterial({
      three.MaterialProperty.vertexColors: true,
      three.MaterialProperty.roughness: 0.74,
      three.MaterialProperty.metalness: 0.02,
      three.MaterialProperty.side: tmath.DoubleSide,
    });
    _coffeeBedMesh = three.Mesh(_bedGeo, bedMat);
    _coffeeBedMesh.visible = false;
    _coffeeBedMesh.receiveShadow = true;
    dripperGroup.add(_coffeeBedMesh);

    // Lapisan air slurry transparan di dalam cone di atas bubuk kopi
    _slurryMat = three.MeshPhysicalMaterial({
      three.MaterialProperty.color: 0x9A481D,
      three.MaterialProperty.transparent: true,
      three.MaterialProperty.opacity: 0.36,
      three.MaterialProperty.roughness: 0.08,
      three.MaterialProperty.clearcoat: 1.0,
      three.MaterialProperty.depthWrite: false,
    });
    _slurryWaterMesh = three.Mesh(geom.CylinderGeometry(0.56, 0.44, 0.04, 34), _slurryMat);
    _slurryWaterMesh.position.setValues(0, 0.46, 0);
    _slurryWaterMesh.visible = false;
    dripperGroup.add(_slurryWaterMesh);

    // Cincin target spiral emas 3D di atas cone
    _targetMat = three.MeshStandardMaterial({
      three.MaterialProperty.color: 0xD4AF37,
      three.MaterialProperty.emissive: tmath.Color.fromHex32(0xD4AF37),
      three.MaterialProperty.transparent: true,
      three.MaterialProperty.opacity: 0.85,
      three.MaterialProperty.roughness: 0.25,
    });
    _targetRingMesh = three.Mesh(geom.TorusGeometry(0.085, 0.011, 10, 26), _targetMat);
    _targetRingMesh.rotation.x = math.pi / 2;
    _targetRingMesh.position.setValues(0, 0.56, 0);
    dripperGroup.add(_targetRingMesh);
  }

  void _buildGooseneckKettle() {
    kettleGroup = three.Group();
    kettleGroup.position.setValues(0.96, 1.38, 0.0);
    rootGroup.add(kettleGroup);

    final matteCharcoal = three.MeshStandardMaterial({
      three.MaterialProperty.color: 0x1D222A,
      three.MaterialProperty.metalness: 0.76,
      three.MaterialProperty.roughness: 0.30,
    });
    final brassMat = three.MeshStandardMaterial({
      three.MaterialProperty.color: 0xD4AF37,
      three.MaterialProperty.metalness: 0.92,
      three.MaterialProperty.roughness: 0.20,
    });
    final spoutSteel = three.MeshStandardMaterial({
      three.MaterialProperty.color: 0x262C36,
      three.MaterialProperty.metalness: 0.82,
      three.MaterialProperty.roughness: 0.24,
    });

    // Badan ketel Fellow Stagg (siluet meruncing ke atas dengan tutup & bibir rapi)
    final bodyProfile = <tmath.Vector2>[
      tmath.Vector2(0.01, -0.22),
      tmath.Vector2(0.39, -0.22),
      tmath.Vector2(0.41, -0.19),
      tmath.Vector2(0.38, 0.14),
      tmath.Vector2(0.33, 0.38),
      tmath.Vector2(0.34, 0.41),
      tmath.Vector2(0.31, 0.42),
      tmath.Vector2(0.29, 0.45),
      tmath.Vector2(0.01, 0.47),
    ];
    final bodyMesh = three.Mesh(geom.LatheGeometry(bodyProfile, segments: 40), matteCharcoal);
    bodyMesh.castShadow = true;
    kettleGroup.add(bodyMesh);

    // Cincin aksen emas & knob tutup ketel
    final lidCollar = three.Mesh(geom.TorusGeometry(0.315, 0.013, 10, 36), brassMat);
    lidCollar.rotation.x = math.pi / 2;
    lidCollar.position.setValues(0, 0.43, 0);
    kettleGroup.add(lidCollar);

    final knob = three.Mesh(geom.CylinderGeometry(0.075, 0.052, 0.085, 24), brassMat);
    knob.position.setValues(0, 0.505, 0);
    knob.castShadow = true;
    kettleGroup.add(knob);

    // Leher angsa S-curve nyata menuju ujung moncong tuang (-X)
    final spoutCurve = curves.CatmullRomCurve3(
      points: [
        tmath.Vector3(-0.34, -0.11, 0),
        tmath.Vector3(-0.56, 0.02, 0),
        tmath.Vector3(-0.78, 0.44, 0),
        _spoutTipLocal.clone(),
      ],
    );
    final spoutMesh = three.Mesh(geom.TubeGeometry(spoutCurve, 26, 0.036, 14, false), spoutSteel);
    spoutMesh.castShadow = true;
    kettleGroup.add(spoutMesh);

    // Bibir cincin kuningan pada ujung moncong gooseneck
    final tipRing = three.Mesh(geom.TorusGeometry(0.036, 0.008, 8, 18), brassMat);
    tipRing.position.setFrom(_spoutTipLocal);
    tipRing.rotation.z = math.pi * 0.35;
    tipRing.rotation.y = math.pi / 2;
    kettleGroup.add(tipRing);

    // Air terlihat sedikit di ujung moncong saat ketel miring
    _kettleSpoutWaterMesh = three.Mesh(
      three.SphereGeometry(0.026, 10, 10),
      three.MeshStandardMaterial({
        three.MaterialProperty.color: 0xE0F2FE,
        three.MaterialProperty.transparent: true,
        three.MaterialProperty.opacity: 0.85,
      }),
    );
    _kettleSpoutWaterMesh.position.setFrom(_spoutTipLocal);
    _kettleSpoutWaterMesh.visible = false;
    kettleGroup.add(_kettleSpoutWaterMesh);

    // Handle counterweight ergonomis di belakang ketel (+X)
    final handleCurve = curves.CatmullRomCurve3(
      points: [
        tmath.Vector3(0.32, 0.31, 0),
        tmath.Vector3(0.66, 0.25, 0),
        tmath.Vector3(0.71, -0.05, 0),
        tmath.Vector3(0.56, -0.14, 0),
        tmath.Vector3(0.37, -0.14, 0),
      ],
    );
    final handleMesh = three.Mesh(
      geom.TubeGeometry(handleCurve, 20, 0.045, 12, false),
      matteCharcoal,
    );
    handleMesh.castShadow = true;
    kettleGroup.add(handleMesh);

    final handleCounter = three.Mesh(geom.CylinderGeometry(0.052, 0.052, 0.09, 18), brassMat);
    handleCounter.position.setValues(0.68, 0.08, 0);
    handleCounter.rotation.z = 0.22;
    kettleGroup.add(handleCounter);
  }

  void _buildDynamicWaterStream() {
    _streamGeo = three.BufferGeometry();
    const int vertCount = (_streamSegments + 1) * (_streamRadial + 1);
    final posList = List<double>.filled(vertCount * 3, 0.0);
    final normList = List<double>.filled(vertCount * 3, 0.0);
    final List<int> indices = [];

    for (int i = 0; i < _streamSegments; i++) {
      for (int j = 0; j < _streamRadial; j++) {
        final a = i * (_streamRadial + 1) + j;
        final b = (i + 1) * (_streamRadial + 1) + j;
        final c = (i + 1) * (_streamRadial + 1) + (j + 1);
        final d = i * (_streamRadial + 1) + (j + 1);
        indices.addAll([a, b, d, b, c, d]);
      }
    }
    _streamGeo.setIndex(indices);
    _streamGeo.setAttributeFromString(
      'position',
      tmath.Float32BufferAttribute.fromList(posList, 3, false),
    );
    _streamGeo.setAttributeFromString(
      'normal',
      tmath.Float32BufferAttribute.fromList(normList, 3, false),
    );

    _streamMat = three.MeshStandardMaterial({
      three.MaterialProperty.color: 0xE0F2FE,
      three.MaterialProperty.emissive: tmath.Color.fromHex32(0x38BDF8),
      three.MaterialProperty.transparent: true,
      three.MaterialProperty.opacity: 0.86,
      three.MaterialProperty.roughness: 0.08,
      three.MaterialProperty.metalness: 0.08,
    });
    _waterStreamMesh = three.Mesh(_streamGeo, _streamMat);
    _waterStreamMesh.visible = false;
    rootGroup.add(_waterStreamMesh);

    _splashMat = three.MeshStandardMaterial({
      three.MaterialProperty.color: 0xE0F2FE,
      three.MaterialProperty.transparent: true,
      three.MaterialProperty.opacity: 0.65,
      three.MaterialProperty.roughness: 0.15,
    });
    _splashRingMesh = three.Mesh(geom.TorusGeometry(0.07, 0.012, 8, 22), _splashMat);
    _splashRingMesh.rotation.x = math.pi / 2;
    _splashRingMesh.visible = false;
    rootGroup.add(_splashRingMesh);
  }

  void _buildDropsAndSteamPools() {
    final dropMat = three.MeshStandardMaterial({
      three.MaterialProperty.color: 0xB45309,
      three.MaterialProperty.roughness: 0.12,
      three.MaterialProperty.transparent: true,
      three.MaterialProperty.opacity: 0.88,
    });
    for (int i = 0; i < 6; i++) {
      final drop = three.Mesh(three.SphereGeometry(0.026, 10, 10), dropMat);
      drop.visible = false;
      rootGroup.add(drop);
      _dropletMeshes.add(drop);
    }

    final steamMat = three.MeshStandardMaterial({
      three.MaterialProperty.color: 0xFFFFFF,
      three.MaterialProperty.transparent: true,
      three.MaterialProperty.opacity: 0.14,
      three.MaterialProperty.roughness: 0.95,
      three.MaterialProperty.depthWrite: false,
    });
    for (int i = 0; i < 10; i++) {
      final puff = three.Mesh(three.SphereGeometry(0.11, 10, 10), steamMat);
      puff.visible = false;
      rootGroup.add(puff);
      _steamMeshes.add(puff);
    }
  }

  /// Sinkronkan seluruh objek 3D PBR terhadap telemetri fisika 120Hz & sensor HP setiap frame render.
  void syncFromSimulation({
    required V603DSimulationSnapshot snapshot,
    required V603DFlameSimulatorGame game,
    required V603DCameraPerspective cameraMode,
  }) {
    final double t = game.ghostSpiralPhase;

    // 1. Posisi & kemiringan Glass Server (termasuk animasi buang air bilasan 60°)
    serverGroup.position.setValues(snapshot.serverTiltRad * 0.42, -1.12, 0);
    serverGroup.rotation.z = -snapshot.serverTiltRad;

    final bool isPreBrew =
        snapshot.interactiveStage == BrewInteractiveStage.wettingPaper ||
        snapshot.interactiveStage == BrewInteractiveStage.liftAndDiscard;
    final double activeVol = isPreBrew ? snapshot.rinseWaterMl : snapshot.serverMl;
    final double maxVol = isPreBrew ? 70.0 : math.max(1.0, snapshot.targetWaterMl);
    final double fillRatio = (activeVol / maxVol).clamp(0.0, 1.0);

    if (fillRatio > 0.01) {
      _serverLiquidMesh.visible = true;
      _serverMeniscusMesh.visible = true;
      _serverLiquidMesh.scale.setValues(1.0, fillRatio, 1.0);
      _serverLiquidMesh.position.setValues(0, 0.03 + 0.32 * fillRatio, 0);
      _serverMeniscusMesh.position.setValues(0, 0.03 + 0.64 * fillRatio, 0);
      final double meniscusScale = 1.0 - 0.14 * fillRatio;
      _serverMeniscusMesh.scale.setValues(meniscusScale, 1.0, meniscusScale);

      final liqMat = _serverLiquidMesh.material as three.MeshStandardMaterial;
      final menMat = _serverMeniscusMesh.material as three.MeshStandardMaterial;
      if (isPreBrew) {
        liqMat.color.setFromHex32(0x93C5FD);
        liqMat.opacity = 0.42;
        menMat.color.setFromHex32(0xBAE6FD);
      } else {
        liqMat.color.setFromHex32(0x6B270E);
        liqMat.opacity = 0.88;
        menMat.color.setFromHex32(0xA44B1A);
      }
    } else {
      _serverLiquidMesh.visible = false;
      _serverMeniscusMesh.visible = false;
    }

    _discardPourStreamMesh.visible = snapshot.serverTiltRad > 0.65 && snapshot.rinseWaterMl > 0.5;

    // 2. Animasi Dripper Hario V60 (Angkat Dripper + Gentle Rao Swirl + Mode X-Ray Cutaway)
    final double swirlR = snapshot.swirlIntensity * 0.055;
    final double swirlX = swirlR * math.cos(game.vortexPhase);
    final double swirlZ = swirlR * math.sin(game.vortexPhase);
    final double liftY = snapshot.dripperLiftProgress * 0.72;
    dripperGroup.position.setValues(swirlX, -0.14 + liftY, swirlZ);
    dripperGroup.rotation.z = snapshot.dripperLiftProgress * 0.06;

    if (cameraMode == V603DCameraPerspective.xrayCutaway) {
      _dripperMat.transparent = true;
      _dripperMat.opacity = 0.28;
      _dripperMat.color.setFromHex32(0xE0F2FE);
    } else {
      _dripperMat.transparent = false;
      _dripperMat.opacity = 1.0;
      _dripperMat.color.setFromHex32(0xFAF5EB);
    }

    // 3. Animasi Membasahi Kertas Filter (kering matte kaku -> lembap transparan menempel rib)
    final double wet = (snapshot.paperWetnessPct / 100.0).clamp(0.0, 1.0);
    final double paperScale = 1.032 - wet * 0.04;
    _paperFilterMesh.scale.setValues(paperScale, 1.0, paperScale);
    _paperMat.roughness = 0.92 - wet * 0.48;
    _paperMat.opacity = cameraMode == V603DCameraPerspective.xrayCutaway
        ? 0.34
        : (0.95 - wet * 0.16);
    _paperMat.color.setValues(
      0.95 - wet * 0.14,
      0.92 - wet * 0.17,
      0.86 - wet * 0.21,
    );

    // 4. Coffee Bed Heightfield 3D & Slurry
    if (snapshot.coffeeGroundsAdded) {
      _coffeeBedMesh.visible = true;
      _updateCoffeeBedGeometry(game.bedSolver, snapshot);
    } else {
      _coffeeBedMesh.visible = false;
    }

    final double slurryLift = (snapshot.slurryMl / 120.0).clamp(0.0, 1.0);
    if (snapshot.coffeeGroundsAdded && slurryLift > 0.02) {
      _slurryWaterMesh.visible = true;
      final double sy = 0.43 + slurryLift * 0.24;
      final double sr = 0.76 + slurryLift * 0.38;
      _slurryWaterMesh.position.setValues(0, sy, 0);
      _slurryWaterMesh.scale.setValues(sr, 1.0, sr);
      if (game.isThermalDropTriggered && snapshot.tempC <= 75.0) {
        _slurryMat.color.setFromHex32(0x38BDF8);
        _slurryMat.opacity = 0.34;
      } else {
        _slurryMat.color.setFromHex32(0x8C3D18);
        _slurryMat.opacity = 0.40;
      }
    } else {
      _slurryWaterMesh.visible = false;
    }

    // 5. Target Ring Emas Berdenyut
    if (!snapshot.isCompleted &&
        cameraMode != V603DCameraPerspective.freeOrbit &&
        snapshot.interactiveStage != BrewInteractiveStage.liftAndDiscard) {
      _targetRingMesh.visible = true;
      final double targetR = snapshot.interactiveStage == BrewInteractiveStage.wettingPaper
          ? 0.44
          : (0.20 + 0.14 * math.sin(t * 0.5));
      _targetRingMesh.position.setValues(
        math.cos(t) * targetR,
        snapshot.interactiveStage == BrewInteractiveStage.wettingPaper ? 0.62 : (0.50 + slurryLift * 0.22),
        math.sin(t) * targetR,
      );
      final double pulse = 1.0 + 0.14 * math.sin(t * 3.0);
      _targetRingMesh.scale.setValues(pulse, pulse, pulse);
    } else {
      _targetRingMesh.visible = false;
    }

    // 6. Ketel Leher Angsa 3D synced 1:1 ke orientasi sensor Gyroscope + posisi spiral
    final bool showKettle = cameraMode != V603DCameraPerspective.freeOrbit;
    kettleGroup.visible = showKettle;
    if (showKettle) {
      final double impX = snapshot.streamImpactNormalized.dx * 0.38;
      final double impZ = snapshot.streamImpactNormalized.dy * 0.38;
      final double pitchRad = (snapshot.pitchDeg * math.pi / 180.0).clamp(0.0, 1.05);
      final double rollRad = (snapshot.rollDeg * math.pi / 180.0).clamp(-0.6, 0.6);

      kettleGroup.position.setValues(
        impX + 0.96,
        1.28 + liftY * 0.35 - pitchRad * 0.14,
        impZ - 0.04,
      );
      kettleGroup.rotation.set(rollRad * 0.45, 0.0, pitchRad * 0.85);
      kettleGroup.updateMatrixWorld(true);

      final tmath.Vector3 spoutTipWorld = _spoutTipLocal.clone()..applyMatrix4(kettleGroup.matrixWorld);
      final double hitWorldY = dripperGroup.position.y +
          (snapshot.interactiveStage == BrewInteractiveStage.wettingPaper
              ? 0.58
              : (0.44 + slurryLift * 0.22));
      final tmath.Vector3 impactWorld = tmath.Vector3(impX, hitWorldY, impZ);

      _kettleSpoutWaterMesh.visible = snapshot.flowRateMlS > 0.2;
      if (snapshot.flowRateMlS > 0.2) {
        _updateParabolicWaterStream(
          start: spoutTipWorld,
          end: impactWorld,
          snapshot: snapshot,
          isCold: game.isThermalDropTriggered && snapshot.tempC <= 75.0,
          phase: t,
        );
      } else {
        _waterStreamMesh.visible = false;
        _splashRingMesh.visible = false;
      }
    } else {
      _waterStreamMesh.visible = false;
      _splashRingMesh.visible = false;
    }

    // 7. LED Timbangan + Tetesan Darcy + Partikel Uap 3D
    if (snapshot.isBypassWarning) {
      _scaleLedMat.color.setFromHex32(0xEF4444);
      _scaleLedMat.emissive?.setFromHex32(0xDC2626);
    } else if (snapshot.flowRegime == KettleFlowRegime.turbulent) {
      _scaleLedMat.color.setFromHex32(0xF97316);
      _scaleLedMat.emissive?.setFromHex32(0xEA580C);
    } else {
      _scaleLedMat.color.setFromHex32(0x22C55E);
      _scaleLedMat.emissive?.setFromHex32(0x16A34A);
    }

    final bool hasDrops = !snapshot.isCompleted &&
        snapshot.serverTiltRad < 0.25 &&
        ((isPreBrew && snapshot.flowRateMlS > 0.2) || snapshot.slurryMl > 1.2);
    for (int i = 0; i < _dropletMeshes.length; i++) {
      final drop = _dropletMeshes[i];
      if (!hasDrops) {
        drop.visible = false;
        continue;
      }
      drop.visible = true;
      final double frac = ((t * 0.9 + i / _dropletMeshes.length) % 1.0);
      final double topDropY = dripperGroup.position.y - 0.04;
      final double botDropY = -1.09 + 0.62 * fillRatio;
      drop.position.setValues(
        swirlX * (1.0 - frac),
        topDropY - frac * math.max(0.05, topDropY - botDropY),
        swirlZ * (1.0 - frac),
      );
    }

    final bool showSteam = snapshot.tempC > 79.0 && (snapshot.flowRateMlS > 0.2 || snapshot.slurryMl > 1.5);
    for (int i = 0; i < _steamMeshes.length; i++) {
      final puff = _steamMeshes[i];
      if (!showSteam) {
        puff.visible = false;
        continue;
      }
      puff.visible = true;
      final double age = ((t * 0.35 + i * 0.17) % 1.0);
      puff.position.setValues(
        math.sin(t + i * 1.4) * 0.26 * age,
        dripperGroup.position.y + 0.62 + age * 0.95,
        math.cos(t * 0.8 + i) * 0.22 * age,
      );
      final double s = 0.65 + age * 1.25;
      puff.scale.setValues(s, s, s);
    }
  }

  void _updateCoffeeBedGeometry(
    V60BedPercolationSolver solver,
    V603DSimulationSnapshot snap,
  ) {
    final posAttr = _bedGeo.getAttributeFromString('position') as tmath.Float32BufferAttribute;
    final colAttr = _bedGeo.getAttributeFromString('color') as tmath.Float32BufferAttribute;
    final Float32List posArr = posAttr.array;
    final Float32List colArr = colAttr.array;
    const int solverN = V60BedPercolationSolver.gridSize;
    final bool bloomGlow = snap.pouredMl > 0.5 && snap.pouredMl < snap.targetWaterMl * 0.5;

    for (int i = 0; i < _bedVertices.length; i++) {
      final v = _bedVertices[i];
      final int sx = ((v.nx * 0.5 + 0.5) * (solverN - 1)).round().clamp(0, solverN - 1);
      final int sy = ((v.nz * 0.5 + 0.5) * (solverN - 1)).round().clamp(0, solverN - 1);
      final int sIdx = sy * solverN + sx;

      final double h = solver.bedHeightGrid[sIdx];
      final double co2 = solver.co2BubbleGrid[sIdx];
      final double wet = solver.localExtractionGrid[sIdx].clamp(0.0, 1.0);

      posArr[i * 3 + 1] = 0.24 + h * 0.26;

      double r = 0.45 * (1.0 - wet) + 0.19 * wet;
      double g = 0.25 * (1.0 - wet) + 0.09 * wet;
      double b = 0.13 * (1.0 - wet) + 0.05 * wet;
      if (bloomGlow && co2 > 0.45) {
        final double foam = ((co2 - 0.45) * 1.1).clamp(0.0, 0.72);
        r = r * (1.0 - foam) + 0.86 * foam;
        g = g * (1.0 - foam) + 0.68 * foam;
        b = b * (1.0 - foam) + 0.44 * foam;
      }
      colArr[i * 3] = r;
      colArr[i * 3 + 1] = g;
      colArr[i * 3 + 2] = b;
    }

    posAttr.needsUpdate = true;
    colAttr.needsUpdate = true;
    _bedGeo.computeVertexNormals();
  }

  void _updateParabolicWaterStream({
    required tmath.Vector3 start,
    required tmath.Vector3 end,
    required V603DSimulationSnapshot snapshot,
    required bool isCold,
    required double phase,
  }) {
    _waterStreamMesh.visible = true;
    _splashRingMesh.visible = true;

    final int hexCol = snapshot.isBypassWarning
        ? 0xEF4444
        : (isCold ? 0x38BDF8 : 0xE0F2FE);
    _streamMat.color.setFromHex32(hexCol);
    _streamMat.emissive?.setFromHex32(isCold ? 0x0284C7 : 0x7DD3FC);
    _splashMat.color.setFromHex32(hexCol);

    final posAttr = _streamGeo.getAttributeFromString('position') as tmath.Float32BufferAttribute;
    final Float32List posArr = posAttr.array;
    final double baseRadius =
        (0.014 + (snapshot.flowRateMlS / 12.0) * 0.022).clamp(0.013, 0.042);

    for (int i = 0; i <= _streamSegments; i++) {
      final double s = i / _streamSegments;
      final double cx = start.x + (end.x - start.x) * s;
      final double cz = start.z + (end.z - start.z) * s;
      final double cy = start.y + (end.y - start.y) * (s * s);

      final double tangentDx = end.x - start.x;
      final double tangentDy = (end.y - start.y) * 2.0 * s - 0.05;
      final double tangentDz = end.z - start.z;
      final tVec = tmath.Vector3(tangentDx, tangentDy, tangentDz)..normalize();
      final refUp = tVec.x.abs() < 0.85 ? tmath.Vector3(1, 0, 0) : tmath.Vector3(0, 0, 1);
      final nVec = _cross(tVec, refUp)..normalize();
      final bVec = _cross(tVec, nVec)..normalize();

      final double shimmer =
          baseRadius * (1.0 - 0.24 * s + 0.10 * math.sin(s * 14.0 - phase * 18.0));

      for (int j = 0; j <= _streamRadial; j++) {
        final double ang = (j / _streamRadial) * math.pi * 2;
        final double cosA = math.cos(ang) * shimmer;
        final double sinA = math.sin(ang) * shimmer;
        final int idx = (i * (_streamRadial + 1) + j) * 3;
        posArr[idx] = cx + nVec.x * cosA + bVec.x * sinA;
        posArr[idx + 1] = cy + nVec.y * cosA + bVec.y * sinA;
        posArr[idx + 2] = cz + nVec.z * cosA + bVec.z * sinA;
      }
    }

    posAttr.needsUpdate = true;
    _streamGeo.computeVertexNormals();

    _splashRingMesh.position.setValues(end.x, end.y + 0.015, end.z);
    final double ringPulse = (0.7 + ((phase * 2.8) % 1.0) * 1.1) *
        (snapshot.flowRegime == KettleFlowRegime.turbulent ? 1.45 : 1.0);
    _splashRingMesh.scale.setValues(ringPulse, ringPulse, ringPulse);
  }

  static tmath.Vector3 _cross(tmath.Vector3 a, tmath.Vector3 b) => tmath.Vector3(
        a.y * b.z - a.z * b.y,
        a.z * b.x - a.x * b.z,
        a.x * b.y - a.y * b.x,
      );
}

class _BedVertexInfo {
  final double nx;
  final double nz;
  const _BedVertexInfo(this.nx, this.nz);
}
