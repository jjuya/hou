class BookmarksController < ApplicationController

  before_action :set_bookmark, only: [:show, :edit, :update, :destroy]

  def index
  end

  def show
    @board = Board.find(@bookmark.board_id)
  end

  def new
    redirect_to root_path
  end

  def create
    bookmark = Bookmark.create(bookmark_params)
    list = List.find(bookmark.list_id)

    redirect_to board_path(list.board_id)
  end

  def edit
    board = List.find(@bookmark.list_id).board
    @lists = board.lists
  end

  def update
    @bookmark.update(bookmark_params)

    list = List.find(@bookmark.list_id)

    redirect_to board_path(list.board_id)
  end

  def destroy
    @bookmark.destroy

    list = List.find(@bookmark.list_id)

    redirect_to board_path(list.board_id)
  end

  private
  def set_bookmark
    @bookmark = Bookmark.find(params[:id])
  end

  def bookmark_params
  	params.require(:bookmark).permit(:title, :url, :description, :list_id, :tag_1, :tag_2, :tag_3)
  end

  def crawl_url
    
    url = params[:src_url]
    iskorean = false
# ============== Make URL ==============================================================    
    # If there is no http://
    unless url[/\Ahttp:\/\//] || url[/\Ahttps:\/\//]
      url = "http://#{url}"
    end
    
    value = check_url(url) # return "body name","tag name", "Mobile Mode"
    
    title_name = value[0]
    body_name = value[1]
    tag_name = value[2]
    mobile_mode = value[3]
    # puts title_name
    # puts body_name
    # puts tag_name
    # puts mobile_mode

    # #checking url
    #mobile_mod check
    if mobile_mode
      url = url.gsub(url.partition("//")[1], url.partition("//")[1]+"m." )
    end
# =======================================================================================

# =================== Crawling ==========================================================
    # #crawling
    response = HTTParty.get(url)
    doc = Nokogiri::HTML(response.body)
    # doc = Nokogiri::HTML(open(url, :allow_redirections => :safe), nil, 'utf-8')
    # doc = Nokogiri::HTML(open(url, :allow_redirections => :safe), nil, 'euc-kr')

    # remove
    doc.css('script').remove
    doc.xpath("//@*[starts-with(name(),'on')]").remove

    # select body
    # title = doc.css('title').text
    title = doc.css(title_name).text
    content = doc.css(body_name).text
    # just tag
    tag = doc.css(tag_name).text
    # body = doc.css('body').text
    # body.gsub!(/<\s*script\s*>|<\s*\/\s*script\s*>/, '')
    
    # Checking Korean
    iskorean = true if content.match(/[가-힣]+/)
   
    all_array = Array.new
    # all_text = content.split(".")
    content = content.gsub("  ","")
    all_text = content.split(/[\?\!\.;]+/)
    p '*******************'
    p content
    all_text.length.times do |i|
      l = all_text[i].strip
      # l.gsub!(/\s+/, "")
      if(l.length > 0)
        # puts l
        all_text[i] = l
        # all_array << l
      end
    end
p '~~~~~~~~~~~~~~~~~~~~~~'
    p all_text
    # all_text.gsub(/<\s*script\s*>|<\s*\/\s*script\s*>/, '')
# =======================================================================================
# =============== English NLP ===========================================================
    
    # top keyword 3
    tag = content.topics[0..2] 
    
    # summarize sentence
    docu = content.summarize(percent: 20)
    
# =======================================================================================  

# Warning It need to JAVA Install

# =============== Korean NLP ============================================================
    # twitter NLP
    processor = TwitterKorean::Processor.new
    # Noralize
    # twitter = processor.normalize(all_text)
    # Tokenize
    # twitter = processor.tokenize(all_text)
    # Stemming
    twitter = Array.new
    all_text.each do |s|
      twitter << processor.stem(s)
    end
    
    # p twitter
    # p tag
    # p '======================'
    # extract pharases
    # twitter = processor.extract_phrases(all_text)
    # twitter = processor.extract_phrases(all_text).first.metadata


    # hashtag
    metadata = Array.new
    twitter.length.times do |i|
      twitter[i].each do |t|
        metadata << t if t.metadata.pos == :hashtag # t.metadata
        # puts t.metadata
      end
    end

    # words_count
    word = Hash.new(0)
    twitter.length.times do |i|
      twitter[i].each do |t|
        if word.has_key? t
          word[t] += 1 if t.metadata.pos == :noun # :hasttag
        else
          word.store(t, 1) if t.metadata.pos == :noun
        end
      end
    end
    word = word.sort_by {|k, v| v}.reverse.to_h
# =======================================================================================    
  
# ================== TF-IDF Model =======================================================    
  puts all_text.class
  puts all_text[0].class
  idf = Array.new
  all_text.each do |at|
    # puts at
    idf << TfIdfSimilarity::Document.new(at)
    # puts idf
  end
  idf << TfIdfSimilarity::Document.new(title)

  model = TfIdfSimilarity::TfIdfModel.new(idf, :library => :narray)

  tfidf_by_term = {}
  # idf[7].terms.each do |tff|
  #   tfidf_by_term[tff] = model.tfidf(idf[7], tff)
  # end
  # idf.each do |i|
  #   i.terms.each do |t|
  #     tfidf_by_term[t] = model.tfidf(i, t)
  #   end
  # end
  idf[-1].terms.each do |term|
    tfidf_by_term[term] = model.tfidf(idf[-1], term)
  end
  tf = tfidf_by_term.sort_by{|_,tfidf| -tfidf}
# =======================================================================================
  # puts "+++++++++++++++++++++++++++++++++"
  # tf.each do |tt|
  #   puts tt
  # end
  # puts tf
    
    # puts "====="
    # puts word
    # puts "================="
    # puts twitter.first.metadata.pos
    # puts "================="

    # puts "================="
    # puts word
    # puts "================="

    tag1 = tf[-1][0]
    tag2 = word.keys[0]
    tag3 = word.keys[1]

    Post.create(
      title: title,
      src_url: params[:src_url],
      tag1: tag1,
      tag2: tag2,
      tag3: tag3,
      desc: params[:desc], #대략적인 설명
      html: all_text, #all_text, # all_arra y# text | body
      words: word #word twitter # word # NLP fuction 비교
      )
    redirect_to root_path
  end
  
  def check_url(url)
      #div_775
      crawl_hash= {
        "cafe.naver"    => ["h2.tit","#ct",nil,true],
        "blog.naver"    => ["h3.se_textarea",".__se_component_area",".post_tag",true],
        "cafe.daum"     => ["h3.tit_subject","#daumWrap",nil,true],
        "blog.daum"     => ["h3.tit_view","#article","#tagListLayer_11777182",true],
        "stackoverflow" => ["title","#mainbar",nil,false],
        "github"        => ["title","#readme","body",false],
        "brunch"        => ["title",".wrap_view_article",nil,false],
        "tistory"       => [".titleWrap","#body > div.article > div > div", ".tag_label", false]
      }

      def_val = ["title","body",nil,false] # crawl_hash에 지정되어 있지 않은 도메인의 url

      # "body name","tag name", "Mobile Mode"
      crawl_hash.each do |key, val|
        p val[1]
        p val[2]
        unless url[key].nil?
          val[-1] = false unless url["/m."].nil?
          #key가 crawo_hash에 있는 경우, key에 해당하는 val값이 return
          p val
          return val
        end
      end

      return def_val
    end
end
