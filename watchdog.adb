--  watchdog.adb
--  
--  Watchdog Timer – Safety-critical heartbeat monitor
--  
--  This package implements a safety-critical watchdog timer.
--  The watchdog must be periodically "kicked" (reset) to prevent a system
--  reset or failure indication. If the watchdog is not kicked within the
--  configured timeout period, it triggers a safety action (e.g., system reset).
--
--  Author: Sternenfisch
--  License: MIT

with Ada.Real_Time; use Ada.Real_Time;

package body Watchdog is

   --  Initialize the watchdog with a configuration
   procedure Initialize (
      Instance   : in out Watchdog_Instance;
      Config     : Watchdog_Configuration
   ) is
   begin
      Instance.Config := Config;
      Instance.Last_Kick := Clock;
      Instance.State := Armed;
   end Initialize;

   --  Kick the watchdog (reset the timer)
   procedure Kick (Instance : in out Watchdog_Instance) is
   begin
      if Instance.State = Armed then
         Instance.Last_Kick := Clock;
      end if;
   end Kick;

   --  Check if the watchdog has triggered
   function Has_Triggered (Instance : Watchdog_Instance) return Boolean is
   begin
      return Instance.State = Triggered;
   end Has_Triggered;

   --  Get the current state of the watchdog
   function Get_State (Instance : Watchdog_Instance) return Watchdog_State is
   begin
      return Instance.State;
   end Get_State;

   --  Disable the watchdog (for maintenance or shutdown)
   procedure Disable (Instance : in out Watchdog_Instance) is
   begin
      Instance.State := Disabled;
   end Disable;

   --  Enable the watchdog (after initialization or disable)
   procedure Enable (Instance : in out Watchdog_Instance) is
   begin
      if Instance.State /= Triggered then
         Instance.State := Armed;
         Instance.Last_Kick := Clock;
      end if;
   end Enable;

   --  Get the remaining time until the watchdog triggers
   function Time_Remaining (Instance : Watchdog_Instance) return Time_Span is
      Now : constant Time := Clock;
      Elapsed : Time_Span := Now - Instance.Last_Kick;
   begin
      if Instance.State = Armed then
         if Elapsed >= Instance.Config.Timeout then
            --  Timeout has occurred, trigger the action
            Instance.State := Triggered;
            if Instance.Config.Action /= null then
               Instance.Config.Action.all;
            end if;
            return Time_Span_Zero;
         else
            return Instance.Config.Timeout - Elapsed;
         end if;
      else
         return Time_Span_Zero;
      end if;
   end Time_Remaining;

begin
   --  Optional: Initialize a default watchdog instance if needed
   null;

end Watchdog;
