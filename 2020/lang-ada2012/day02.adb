with Ada.Text_IO;
with Ada.Integer_Text_IO;

procedure Day02 is

	procedure Part1 is
		File          : Ada.Text_IO.File_Type;
		Min, Max      : Positive;
		Dummy_Char    : Character;
		Test_Char     : Character;
		Password_Char : Character;
		Counter       : Integer;
		Num_Valid     : Integer := 0;
	begin
		Ada.Text_IO.Open (File => File, Mode => Ada.Text_IO.In_File, Name => "../input/day02.txt");
		while not Ada.Text_IO.End_Of_File (File) loop
			Ada.Integer_Text_IO.Get (File, Min);
			Ada.Text_IO.Get (File, Dummy_Char);
			Ada.Integer_Text_IO.Get (File, Max);
			Ada.Text_IO.Get (File, Dummy_Char);
			Ada.Text_IO.Get (File, Test_Char);
			Ada.Text_IO.Get (File, Dummy_Char);
			Ada.Text_IO.Get (File, Dummy_Char);
			Counter := 0;
			loop
				Ada.Text_IO.Get (File, Password_Char);
				if Password_Char = Test_Char then
					Counter := Counter + 1;
				end if;
				exit when Ada.Text_IO.End_Of_Line (File);
			end loop;
			if Counter >= Min and Counter <= Max then
				Num_Valid := Num_Valid + 1;
			end if;
		end loop;
		Ada.Text_IO.Put ("Part1:" & Integer'Image (Num_Valid));
		Ada.Text_IO.New_Line;
		Ada.Text_IO.Close (File);
	end;

	procedure Part2 is
		File          : Ada.Text_IO.File_Type;
		Pos1, Pos2    : Positive;
		Dummy_Char    : Character;
		Test_Char     : Character;
		Password_Char : Character;
		Counter       : Integer;
		Current_Pos   : Integer;
		Num_Valid     : Integer := 0;
	begin
		Ada.Text_IO.Open (File => File, Mode => Ada.Text_IO.In_File, Name => "../input/day02.txt");
		while not Ada.Text_IO.End_Of_File (File) loop
			Ada.Integer_Text_IO.Get (File, Pos1);
			Ada.Text_IO.Get (File, Dummy_Char);
			Ada.Integer_Text_IO.Get (File, Pos2);
			Ada.Text_IO.Get (File, Dummy_Char);
			Ada.Text_IO.Get (File, Test_Char);
			Ada.Text_IO.Get (File, Dummy_Char);
			Ada.Text_IO.Get (File, Dummy_Char);
			Current_Pos := 1;
			Counter := 0;
			loop
				Ada.Text_IO.Get (File, Password_Char);
				if Password_Char = Test_Char then
					if Current_Pos = Pos1 or Current_Pos = Pos2 then
						Counter := Counter + 1;
					end if;
				end if;
				Current_Pos := Current_Pos + 1;
				exit when Ada.Text_IO.End_Of_Line (File);
			end loop;

			if Counter = 1 then
				Num_Valid := Num_Valid + 1;
			end if;
		end loop;
		Ada.Text_IO.Put ("Part2:" & Integer'Image (Num_Valid));
		Ada.Text_IO.New_Line;
		Ada.Text_IO.Close (File);
	end;

begin
	Part1;
	Part2;
end;