class BookmarksController < ApplicationController

  before_action :set_bookmark, only: [:show, :edit, :update, :destroy]

  def index
    redirect_to root_path
  end

  def show
    redirect_to root_path
  end

  def new
    redirect_to root_path
  end

  def create
    bookmark = Bookmark.create(bookmark_params)
    list = List.find(bookmark.list_id)

    if bookmark.save
      redirect_to board_path(list.board_id)
    else
      flash[:toastr] = { "error" => "Error: Not Bookmark Bookmark" }
      redirect_to board_path(list.board_id)
    end
  end

  def edit
    redirect_to root_path
  end

  def update
    @bookmark.update(bookmark_params)

    list = List.find(@bookmark.list_id)

    if @bookmark.save
      redirect_to board_path(list.board_id)
    else
      flash[:toastr] = { "error" => "Error: Not Update Bookmark" }
      redirect_to board_path(list.board_id)
    end
  end

  def destroy
    @bookmark.destroy

    list = List.find(@bookmark.list_id)

    if @bookmark.save
      redirect_to board_path(list.board_id)
    else
      flash[:toastr] = { "error" => "Error: Not Destroy Bookmark" }
      flash[:error] = "Error: Not Destroy Bookmark"
      redirect_to board_path(list.board_id)
    end
  end

  private
  def set_bookmark
    @bookmark = Bookmark.find(params[:id])
  end

  def bookmark_params
<<<<<<< HEAD
  	params.require(:bookmark).permit(:title, :url, :description, :list_id, :tag_1, :tag_2, :tag_3, :rating)
=======
  	
  	if params[:action].eql? "create"
  	  ext_tag(params[:bookmark][:url]).permit! 
  	else # when Edit
  	  params.require(:bookmark).permit(:title, :url, :description, :list_id, :tag_1, :tag_2, :tag_3)
  	end
  	
>>>>>>> c80cd91f712a56cd861818132056b26585f19d93
  end

  def ext_tag(url)

    iskorean = false
   
    # If there is no http://
    unless url[/\Ahttp:\/\//] || url[/\Ahttps:\/\//]
      url = "http://#{url}"
    end
    
    value = check_url(url) # return "body name","tag name", "Mobile Mode"
    
    title_name = value[0]
    body_name = value[1]
    tag_name = value[2]
    mobile_mode = value[3]

    if mobile_mode
      url = url.gsub(url.partition("//")[1], url.partition("//")[1]+"m." )
    end
# =======================================================================================

# =================== Crawling ==========================================================
    # #crawling
    response = HTTParty.get(url)
    doc = Nokogiri::HTML(response.body)
    
    # remove
    doc.css('script').remove
    doc.xpath("//@*[starts-with(name(),'on')]").remove

    title = doc.css(title_name).text
    content = doc.css(body_name).text
    tag = doc.css(tag_name).text

    # Checking Korean
    iskorean = true if content.match(/[가-힣]+/)
   
    content = content.gsub("  ","")
    content = content.gsub("\n","")

    if iskorean
      all_text = content.split(/[\?\!\.;]+/)
      all_text.length.times do |i|
        l = all_text[i].strip
        if(l.length > 0)
          all_text[i] = l
        end
      end
      content = all_text
    end

    tag = Array.new

    # twitter KoNLP / TF-IDF model

    tag = iskorean ? kor_tag(content,title) : en_tag(content)

    params[:bookmark][:tag_1] = tag[0]
    params[:bookmark][:tag_2] = tag[1]
    params[:bookmark][:tag_3] = tag[2]
    
    return params[:bookmark]
   
  end
  
  # =============== English NLP ===========================================================
  def en_tag(content)  
    content = content.gsub(/[#=><]+/,"")
    aticle = OTS.parse(content)
    tag = Array.new

    # top keyword 3
    aticle.topics[0..2].each do |t|
      tag << t
    end
    return tag
  end
  
# =============== Korean NLP ============================================================
#     Warning It need to JAVA Install
# ---------------------------------------------------------------------------------------
  def kor_tag(all_text, title)
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
   
    tag = Array.new
    
    tag << tf_idf(all_text, title)[-1][0]
    tag << word.keys[0]
    tag << word.keys[1]
    
    return tag
  end
  
  def tf_idf(all_text, title)
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
        # p val[1]
        # p val[2]
        unless url[key].nil?
          val[-1] = false unless url["/m."].nil?
          #key가 crawo_hash에 있는 경우, key에 해당하는 val값이 return
          # p val
          return val
        end
      end

      return def_val
    end
end
