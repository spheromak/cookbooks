# Author:: Jesse Nelson <spheromak@gmail.com>
#
#
class Chef
  class Resource
    class Wiki < Chef::Resource

      def initialize(name, node=nil)
        super(name, node)
        @resource_name = :wiki
        @title = name
        @action = :write
        @user = nil
        @pass = nil
        @space = nil
        @page_id = nil
        @content = nil
        @version = nil
        @url = nil
        @allowed_actions.push(:write)
      end
   
      def title(arg=nil)
        set_or_return( :title, arg, :kind_of => [ String ])
      end

      def page_id(arg=nil)
        set_or_return( :page_id, arg, :kind_of => [ String ])
      end
      
      def content(arg=nil)
        set_or_return( :content, arg, :kind_of => [ String ])
      end
      
      def user(arg=nil)
        set_or_return( :user, arg, :kind_of => [ String ])
      end
      
      def pass(arg=nil)
        set_or_return( :pass, arg, :kind_of => [ String ])
      end

      def space(arg=nil)
        set_or_return( :space, arg, :kind_of => [ String ])
      end

      def url(arg=nil)
        set_or_return( :url, arg, :kind_of => [ String ])
      end
      
      def version(arg=nil)
        set_or_return( :version, arg, :kind_of => [ String ])
      end

    end
  end

  class Provider 
    class Wiki < Chef::Provider
    
      def load_current_resource
        @have_content = nil
        @current_resource = Chef::Resource::Wiki.new(@new_resource.name)
        @wiki = Confluence::Server.new(@new_resource.url)   
        @wiki.login(@new_resource.user, @new_resource.pass)
        page = @wiki.getPage(@new_resource.page_id)
        @new_resource.version page['version']
        @current_resource.title   page['title']
        @current_resource.version page['version']
        @current_resource.content page['content']

        @have_content = true if (@current_resource.content == @new_resource.content) && (@new_resource.title == @current_resource.title)
      end
     
      def action_write
        return if @have_content
        Chef::Log.info("writing new wiki page
                      space: #{@new_resource.space}
                      title: #{@new_resource.title}
                    page_id: #{@new_resource.page_id}
                    version: #{@new_resource.version} ")

        @wiki.storePage( {
          "space"   => @new_resource.space,
          "title"   => @new_resource.title,
          "id"      => @new_resource.page_id,
          "version" => @new_resource.version,
          "content" => @new_resource.content 
        }) 
      end

    end
  end
end

Chef::Platform.platforms[:default].merge!( :wiki => Chef::Provider::Wiki )

