module Rubomop
  class NamedMop < Literal::Object
    prop :todo_file, TodoFile, reader: :public, writer: :public
    prop :name, String, reader: :public, writer: :public
    prop :verbose, _Boolean, reader: :public, writer: :public
    prop :run_rubocop, _Boolean, reader: :public, writer: :public

    def mop!
      todo_file.cop_for(name).deactivate
    end

  end
end
