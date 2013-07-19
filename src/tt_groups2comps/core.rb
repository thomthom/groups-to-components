#-------------------------------------------------------------------------------
#
# Thomas Thomassen
# thomas[at]thomthom[dot]net
#
#-------------------------------------------------------------------------------

require 'sketchup.rb'
begin
  require 'TT_Lib2/core.rb'
rescue LoadError => e
  module TT
    if @lib2_update.nil?
      url = 'http://www.thomthom.net/software/sketchup/tt_lib2/errors/not-installed'
      options = {
        :dialog_title => 'TT_Lib² Not Installed',
        :scrollable => false, :resizable => false, :left => 200, :top => 200
      }
      w = UI::WebDialog.new( options )
      w.set_size( 500, 300 )
      w.set_url( "#{url}?plugin=#{File.basename( __FILE__ )}" )
      w.show
      @lib2_update = w
    end
  end
end


#-------------------------------------------------------------------------------

if defined?( TT::Lib ) && TT::Lib.compatible?( '2.7.0', 'Groups to Components' )

module TT::Plugins::GroupsToComponents


  ### MENU & TOOLBARS ### ------------------------------------------------------

  unless file_loaded?( __FILE__ )
    m = TT.menu( 'Plugins' )
    m.add_item('Convert Groups to Components')  { self.groups2comps }
  end


  ### MAIN SCRIPT ### ----------------------------------------------------------

  def self.groups2comps
    model = Sketchup.active_model
    TT::Model.start_operation('Groups to Components')

    if model.selection.empty?
      entities = model.active_entities.to_a
    else
      entities = model.selection.to_a
    end

    new_instances = []

    entities.each { |e|
      next unless e.is_a?(Sketchup::Group)
      # When SketchUp converts Groups to Components it gives the instance the name of the group
      # and names the definition something like 'Group#123".
      # Here this is swapped around so the definition takes on the name of the group.
      name = e.name
      instance = e.to_component
      unless name.empty?
        instance.definition.name = name
        instance.name = ''
      end

      new_instances << instance
    }

    model.selection.add(new_instances)

    model.commit_operation
  end

end # module

end # if TT_Lib

#-------------------------------------------------------------------------------

file_loaded( __FILE__ )

#-------------------------------------------------------------------------------