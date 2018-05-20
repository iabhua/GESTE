with Ada.Real_Time;

with SDL_Display;
with Keyboard;

with Game_Assets;
with Game_Assets.Tileset;
with Game_Assets.Tileset_Collisions;
with Game_Assets.Level_1;
with Game_Assets.Level_2;

with Levels;
with Player;

with GESTE;
with GESTE_Config;
with GESTE_Fonts.FreeMono5pt7b;

package body Game is

   package RT renames Ada.Real_Time;
   use type RT.Time;
   use type RT.Time_Span;

   package Display is new SDL_Display
     (Width       => 320,
      Height      => 240,
      Pixel_Scale => 4,
      Buffer_Size => 320 * 240);

   Background : constant Display.SDL_Pixel
     := Display.To_SDL_Color (176, 226, 255);

   Black      : constant Display.SDL_Pixel
     := Display.To_SDL_Color (0, 0, 0);

   Text : aliased GESTE.Text.Instance
     (GESTE_Fonts.FreeMono5pt7b.Font,
      15, 1,
      Black,
      GESTE_Config.Transparent);

   Frame_Counter   : Natural := 0;
   Next_FPS_Update : RT.Time := RT.Clock + RT.Seconds (1);

   Period : constant RT.Time_Span := RT.Seconds (1) / 60;
   Next_Release : RT.Time := RT.Clock + Period;

   Lvl : Levels.Level_Id := Levels.Lvl_1;

   ---------------
   -- Game_Loop --
   ---------------

   procedure Game_Loop is
   begin
      loop
         if Player.Position.X > 320 - 3 then
            case Lvl is
               when Levels.Lvl_1 =>
                  Levels.Leave (Levels.Lvl_1);
                  Levels.Enter (Levels.Lvl_2);
                  Lvl := Levels.Lvl_2;
                  Player.Move ((3, 125));
               when Levels.Lvl_2 =>
                  Levels.Leave (Levels.Lvl_2);
                  Levels.Enter (Levels.Lvl_3);
                  Lvl := Levels.Lvl_3;
                  Player.Move ((3, 183));
               when Levels.Lvl_3 =>
                  Levels.Leave (Levels.Lvl_3);
                  Levels.Enter (Levels.Lvl_1);
                  Lvl := Levels.Lvl_1;
                  Player.Move ((3, 142));
            end case;
         elsif Player.Position.X < 2 then
            case Lvl is
               when Levels.Lvl_1 =>
                  Levels.Leave (Levels.Lvl_1);
                  Levels.Enter (Levels.Lvl_3);
                  Lvl := Levels.Lvl_3;
                  Player.Move ((320 - 4, 183));
               when Levels.Lvl_2 =>
                  Levels.Leave (Levels.Lvl_2);
                  Levels.Enter (Levels.Lvl_1);
                  Lvl := Levels.Lvl_1;
                  Player.Move ((320 - 4, 120));
               when Levels.Lvl_3 =>
                  Levels.Leave (Levels.Lvl_3);
                  Levels.Enter (Levels.Lvl_2);
                  Lvl := Levels.Lvl_2;
                  Player.Move ((320 - 4, 25));
            end case;
         end if;

         Keyboard.Update;
         if Keyboard.Pressed (Keyboard.Up) then
            Player.Jump;
         end if;
         if Keyboard.Pressed (Keyboard.Left) then
            Player.Move_Left;
         end if;
         if Keyboard.Pressed (Keyboard.Right) then
            Player.Move_Right;
         end if;
         if Keyboard.Pressed (Keyboard.Esc) then
            return;
         end if;

         Player.Update;

         Frame_Counter := Frame_Counter + 1;

         if Next_FPS_Update <= RT.Clock then
            Next_FPS_Update := RT.Clock + RT.Seconds (1);

            Text.Clear;
            Text.Cursor (1, 1);
            Text.Put ("FPS:" & Frame_Counter'Img);
            Frame_Counter := 0;
         end if;

         GESTE.Render_Dirty
           (Display.Screen_Rect,
            Background,
            Display.Buffer,
            Display.Push_Pixels'Access,
            Display.Set_Drawing_Area'Access);

         delay until Next_Release;
         Next_Release := Next_Release + Period;
      end loop;
   end Game_Loop;

begin
   Levels.Enter (Levels.Lvl_1);
   Player.Move ((3, 142));

   Text.Move ((0, 0));
   GESTE.Add (Text'Access, 10);
   GESTE.Render_All
     (Display.Screen_Rect,
      Background,
      Display.Buffer,
      Display.Push_Pixels'Access,
      Display.Set_Drawing_Area'Access);

end Game;
