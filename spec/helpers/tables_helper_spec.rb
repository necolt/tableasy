require File.dirname(__FILE__) + "/../spec_helper"

describe Tableasy::TablesHelper do
  it "should allow creating table for collection of models" do
    build :project
    output = helper.table_for(Project, [@project], :name)

    output.should == "<table><tr><th>Name</th></tr><tr class=\"project odd\" id=\"row_project_1\"><td>project</td></tr></table>"
  end

  it "should yield row object with columns and record when creating table using block" do
    build :project
    output = helper.table_for(Project, [@project], :name, :leader) do |row|
      row.columns[0].value = row.record.name
      row.columns[1].value = 'xxxxx'
    end

    output.should == "<table><tr><th>Name</th><th>Leader</th></tr><tr class=\"project odd\" id=\"row_project_1\"><td>project</td><td>xxxxx</td></tr></table>"
  end

  it "should allow passing custom html options for row and columns" do
    build :project
    output = helper.table_for(Project, [@project], :name) do |row|
      row.title = 'my row'
      row.html[:class] = 'my-row'
      row.columns[0].align = 'center'
      row.columns[0].html[:class] = 'name'
    end

    output.should == "<table><tr><th>Name</th></tr><tr class=\"project my-row\" id=\"row_project_1\" title=\"my row\"><td align=\"center\" class=\"name\">project</td></tr></table>"
  end

  it "should allow creating a table with totals row" do
    build :admin, :andrius
    output = helper.table_for(Person, [@admin, @andrius], :name, :id, :total => true)

    output.should == "<table>\
<tr><th>Name</th><th>Id</th></tr>\
<tr class=\"person odd\" id=\"row_person_1\"><td>Admin</td><td>1</td></tr>\
<tr class=\"person even\" id=\"row_person_1\"><td>Andrius</td><td>1</td></tr>\
<tr class=\"tableasy_total total-row\" id=\"row_tableasy_total_2\"><th>Total: </th><td>2</td></tr>\
</table>"
  end

  it "should allow creating custom total row" do
    build :admin, :andrius
    output = helper.table_for(Person, [@admin, @andrius], :name, :id, :total => true) do |row|
      row.columns[0].value = 'Total of:' if row.total_row?
      row.columns[1].value = "@#{row.record.id}"
    end

    output.should == "<table>\
<tr><th>Name</th><th>Id</th></tr>\
<tr class=\"person odd\" id=\"row_person_1\"><td>Admin</td><td>@1</td></tr>\
<tr class=\"person even\" id=\"row_person_1\"><td>Andrius</td><td>@1</td></tr>\
<tr class=\"tableasy_total total-row\" id=\"row_tableasy_total_2\"><th>Total of:</th><td>@2</td></tr>\
</table>"
  end

  it "should allow using formatters" do
    build :andrius
    output = helper.table_for(Person, [@andrius], helper.linked(:name))

    output.should == "<table><tr><th>Name</th></tr><tr class=\"person odd\" id=\"row_person_1\"><td><a href=\"/people/Andrius\">Andrius</a></td></tr></table>"
  end

  it "should allow using formatters with totals" do
    build :andrius, :admin
    @andrius.stubs(:id2).returns(@andrius.id * 2)
    @admin.stubs(:id2).returns(@admin.id * 2)
    output = helper.table_for(Person, [@admin, @andrius], :name, :id2, helper.with_percent(:id, :id2), :total => true)

    output.should == "<table>\
<tr><th>Name</th><th>Id2</th><th>Id</th></tr>\
<tr class=\"person odd\" id=\"row_person_1\"><td>Admin</td><td>2</td><td>1 (50.000%)</td></tr>\
<tr class=\"person even\" id=\"row_person_1\"><td>Andrius</td><td>2</td><td>1 (50.000%)</td></tr>\
<tr class=\"tableasy_total total-row\" id=\"row_tableasy_total_2\"><th>Total: </th><td>4</td><td>2 (50.000%)</td></tr>\
</table>"
  end

  it "should not add nil column headers" do
    build :andrius
    output = helper.table_for(Person, [@andrius], helper.tail_link('show'))

    output.should == "<table><tr></tr><tr class=\"person odd\" id=\"row_person_1\"><td><a href=\"/people/Andrius\">show</a></td></tr></table>"
  end

  it "should allow passing custom html options to table" do
    build :project
    output = helper.table_for(Project, [@project], :name, :html => {:id => 'my_table'})
    output.should == "<table id=\"my_table\"><tr><th>Name</th></tr><tr class=\"project odd\" id=\"row_project_1\"><td>project</td></tr></table>"
  end

  it "should allow building vertical tables" do
    build :andrius
    output = helper.table_for(Person, [@andrius, @andrius, @andrius], :name, :id, :format => :vertical, :headers => 'Vertical Table')

    output.should == "<table><tr><th colspan=\"2\">Vertical Table</th></tr>\
<tr class=\"person odd\" id=\"row_person\"><td>name</td><td>Andrius</td><td>Andrius</td><td>Andrius</td></tr>\
<tr class=\"person even\" id=\"row_person\"><td>id</td><td>1</td><td>1</td><td>1</td></tr>\
</table>"
  end
end
