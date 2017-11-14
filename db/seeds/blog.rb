def create_blog_post(title)
  BlogPost.create {
    title: title,
    text: LOREM_IPSUM,
    publish_at: DateTime.now
  }
end

['Foo Fighters', 'Audioslave', 'Aerosmith', 'Alient Ant Farm', '3 Doors Down'].each { |t| create_blog_post(t) }

