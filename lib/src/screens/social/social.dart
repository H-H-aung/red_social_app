part of '../../app.dart';

class SocialPage extends StatelessWidget {
  const SocialPage({super.key});

  static const _platforms = <ServiceItem>[
    ServiceItem(icon: Icons.camera_alt_rounded, label: 'Instagram', services: 'View services'),
    ServiceItem(icon: Icons.music_note_rounded, label: 'TikTok', services: 'View services'),
    ServiceItem(icon: Icons.play_arrow_rounded, label: 'YouTube', services: 'View services'),
    ServiceItem(icon: Icons.facebook_rounded, label: 'Facebook', services: 'View services'),
    ServiceItem(icon: Icons.send_rounded, label: 'Telegram', services: 'View services'),
    ServiceItem(icon: Icons.alternate_email_rounded, label: 'Threads', services: 'View services'),
    ServiceItem(icon: Icons.close_rounded, label: 'Twitter', services: 'View services'),
  ];

  @override
  Widget build(BuildContext context) {
    return _PageFrame(
      title: 'Social Services',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Choose a platform', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          const Text('Latest prices and categories are loaded from the API.', style: TextStyle(color: Color(0xFF7F8898), fontSize: 12, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          for (final platform in _platforms) ...[
            SizedBox(
              height: 112,
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => SocialOrderFormPage(platform: platform))),
                  child: _PlatformCard(item: platform),
                ),
              ),
            ),
            if (platform != _platforms.last) const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}
