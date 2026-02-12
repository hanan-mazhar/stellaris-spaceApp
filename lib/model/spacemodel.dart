class Spacemodel {
  late String Title;
  late String Desc;
  late String Image;
  late String Date; // NASA API date hamesha String hoti hai (e.g. "2026-02-11")

  Spacemodel({
    this.Title = '',
    this.Date = '',
    this.Desc = '',
    this.Image = ''
  });

  factory Spacemodel.fromMap(Map Data) {
    return Spacemodel(
      // NASA ki mukhtalif APIs ke liye multiple keys handle ki hain
      Title: Data['title'] ?? Data['nasa_id'] ?? 'Space Object',
      
      // Planets k liye 'hdurl', Missions/Galaxy k liye 'url' ya 'href'
      Image: Data['hdurl'] ?? Data['url'] ?? Data['img_src'] ?? 'https://via.placeholder.com/300',
      
      Desc: Data['explanation'] ?? Data['description'] ?? 'No description available.',
      
      // Date hamesha String hi rakhein
      Date: Data['date'] ?? Data['date_created'] ?? '',
    );
  }
}