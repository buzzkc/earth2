# Copyright (C) 2007 Rising Sun Pictures and Matthew Landauer
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

# Add a new column 'path' to table directories for redundantly storing
# the full path of the directory.
class AddPathToDirectories < ActiveRecord::Migration
  def self.up
    add_column :directories, :path, :string, :limit => 8192, :null => true

    say_with_time "Updating directories, this might take some time..." do
      Earth::Directory.roots.each do |root|
        root.path = root.name
        setup_children_recursive(root)
      end
    end

    change_column :directories, :path, :string, :limit => 8192, :null => false, :unique => true
    add_index :directories, :path, :unique
  end

  def self.setup_children_recursive(dir)
    dir.save
    dir.children.each do |child|
      child.path = dir.path + "/" + child.name
      setup_children_recursive(child)
    end
  end

  def self.down
    remove_column :directories, :path
  end
end