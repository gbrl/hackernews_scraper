require 'nokogiri'
require 'pp'
require 'open-uri'
require_relative 'color'
require_relative 'post'
require_relative 'comment'

@post = nil

def process_input(argv_input)
  url = argv_input[0]
  puts url
  make_html_file(url)
end

def make_html_file(url)
  open("post.html", "wb") do |file|
    open(url) do |uri|
     file.write(uri.read)
    end
  end
  doc = Nokogiri::HTML(File.open('post.html'))
  parse(doc)
end

def parse(doc)

  # ITEM ID
  item_id = doc.search('.pagetop > a:last-child').map {|link| link['href'] }
  item_id = item_id[1].gsub("%3","").scan(/\d/).join("").to_i

  # URL
  url = "https://news.ycombinator.com/item?id=#{item_id}"

  # TITLE
  title = doc.search('title').inner_text

  # POINTS
  points = doc.search('.subtext > span:first-child').inner_text

  # CREATE POST
  @post = Post.new(title,url,points,item_id)

  # COMMENT USER
  comments_section   = doc.search('table.comment-tree')

  all_comments_boxes = comments_section.search('td.default').map
  all_reply_links    = comments_section.search('div.reply').map 
  all_comments_spans = comments_section.search('span.comment').map 
  all_comments       = comments_section.search('td.default > span.comment').map { |comment| comment.inner_text.gsub("  ","").gsub("-----","").gsub("\n\nreply\n\n","") unless comment.nil?}
  all_ages           = comments_section.search('span.age').map { |age| age.inner_text}
  all_users          = comments_section.search('span.comhead > a').map { |user| user.inner_text.gsub("  ","")}

  puts "Found #{all_comments_boxes.count} comment."
  puts "Found #{all_reply_links.count} reply links."
  puts "Found #{all_comments.length} comments."
  puts "Found #{all_users.length} usernames."
  puts "Found #{all_ages.length} timestamps."

  all_comments_boxes.count.times do |i|
    @post.add_comment(Comment.new(all_comments[i-1],all_users[i-1],all_ages[i-1]))
  end
  output_comments(@post)

end

def output_comments(post)
  post.comments.each do |comment|
    puts blue(comment.username)
    puts red(comment.age)
    puts green(comment.content)
    puts yellow("\n. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .\n")
  end
end

process_input(ARGV)

# EXAMPLE URLs
# https://news.ycombinator.com/item?id=7663775
# https://news.ycombinator.com/item?id=7663774