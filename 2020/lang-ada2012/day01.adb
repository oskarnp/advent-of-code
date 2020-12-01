with Ada.Text_IO;

procedure Day01 is

	type Index is range 1 .. 200;
	type Numbers_Array is array (Index) of Long_Integer;

	procedure Get_Input (A : in out Numbers_Array) is
		package TIO renames Ada.Text_IO;
		I    : Index := 1;	
		File : TIO.File_Type;
	begin
		TIO.Open (File => File,
		          Mode => TIO.In_File,
		          Name => "../input/day01.txt");
		while not TIO.End_Of_Line (File) loop
			A (I) := Long_Integer'Value (TIO.Get_Line (File));
			exit when I = Index'Last;
			I := I + 1;
		end loop;
	end;

	procedure Part1 (A : in Numbers_Array) is
	begin
		for I in A'Range loop
			for J in A'Range loop
				if A(I) + A(J) = 2020 then
					Ada.Text_IO.Put("Part1:");
					Ada.Text_IO.Put (Long_Integer'Image (A(I) * A(J)));
					Ada.Text_IO.New_Line;
					return;
				end if;
			end loop;
		end loop;
	end;

	procedure Part2 (A : in Numbers_Array) is
	begin
		for I in A'Range loop
			for J in A'Range loop
				for K in A'Range loop
					if A(I) + A(J) + A(K) = 2020 then
						Ada.Text_IO.Put("Part2:");
						Ada.Text_IO.Put (Long_Integer'Image (A(I) * A(J) * A(K)));
						Ada.Text_IO.New_Line;
						return;
					end if;
				end loop;
			end loop;
		end loop;
	end;

	Numbers : Numbers_Array;

begin
	Get_Input (Numbers);
	Part1 (Numbers);
	Part2 (Numbers);
end;

