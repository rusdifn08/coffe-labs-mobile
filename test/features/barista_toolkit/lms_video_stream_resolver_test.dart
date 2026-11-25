import 'package:flutter_test/flutter_test.dart';

import 'package:coffee_hub_mobile/features/barista_toolkit/data/lms_video_stream_resolver.dart';

void main() {
  const railwayBase = 'https://coffe-labs-backend-production.up.railway.app';

  test('prioritizes Railway Object Storage HLS & MP4 even when backend returns Cloudinary URL', () {
    final candidates = LmsVideoStreamResolver.buildRemoteCandidates(
      subchapterCode: '1.1',
      apiBaseUrl: railwayBase,
      serverUrl:
          'https://res.cloudinary.com/demo/video/upload/sp_auto/coffeelabs/lms/bab1/sub_1_1_bcc.m3u8',
    );

    expect(candidates.length, 4);
    expect(
      candidates[0].url,
      '$railwayBase/api/v1/toolkit/object-storage/coffeelabs/lms/bab1/sub_1_1_bcc.m3u8',
    );
    expect(
      candidates[0].fallbackMp4Url,
      '$railwayBase/api/v1/toolkit/object-storage/coffeelabs/lms/bab1/sub_1_1_bcc.mp4',
    );
    expect(
      candidates[1].url,
      '$railwayBase/api/v1/toolkit/object-storage/coffeelabs/lms/bab1/sub_1_1_bcc.mp4',
    );
    expect(candidates[2].url, contains('res.cloudinary.com'));
    expect(candidates[3].url, endsWith('.mp4'));
  });

  test('extracts stem dynamically for future Bab 2-9 lessons from serverUrl', () {
    final candidates = LmsVideoStreamResolver.buildRemoteCandidates(
      subchapterCode: '2.1',
      apiBaseUrl: railwayBase,
      serverUrl:
          'https://res.cloudinary.com/demo/video/upload/sp_auto/coffeelabs/lms/bab2/sub_2_1_v60.m3u8',
    );

    expect(
      candidates.first.url,
      '$railwayBase/api/v1/toolkit/object-storage/coffeelabs/lms/bab2/sub_2_1_v60.m3u8',
    );
    expect(
      LmsVideoStreamResolver.posterUrlFor(
        subchapterCode: '2.1',
        apiBaseUrl: railwayBase,
        serverUrl:
            'https://res.cloudinary.com/demo/video/upload/sp_auto/coffeelabs/lms/bab2/sub_2_1_v60.m3u8',
      ),
      '$railwayBase/api/v1/toolkit/object-storage/coffeelabs/lms/bab2/sub_2_1_v60_poster.png',
    );
  });

  test('generates Bab 1 poster URL directly from subchapterCode when serverUrl is absent', () {
    expect(
      LmsVideoStreamResolver.posterUrlFor(
        subchapterCode: '1.4',
        apiBaseUrl: '$railwayBase/',
      ),
      '$railwayBase/api/v1/toolkit/object-storage/coffeelabs/lms/bab1/sub_1_4_paragon_poster.png',
    );
  });
}
