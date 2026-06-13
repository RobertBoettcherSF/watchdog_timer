--  watchdog.ads
--  
--  Watchdog Timer – Safety-critical heartbeat monitor
--  
--  This package provides a safety-critical watchdog timer implementation.
--  The watchdog must be periodically "kicked" (reset) to prevent a system
--  reset or failure indication. If the watchdog is not kicked within the
--  configured timeout period, it triggers a safety action (e.g., system reset).
--
--  Author: Sternenfisch
--  License: MIT

with Ada.Real_Time; use Ada.Real_Time;

package Watchdog is

   --  Configuration for the watchdog timer
   type Watchdog_Configuration is record
      Timeout : Time_Span;  --  Maximum allowed time between kicks
      Action  : access procedure;  --  Procedure to call on timeout (e.g., reset system)
   end record;

   --  Watchdog state
   type Watchdog_State is (Armed, Triggered, Disabled);

   --  Watchdog instance (limited to ensure single instance for safety)
   type Watchdog_Instance is limited private;

   --  Initialize the watchdog with a configuration
   procedure Initialize (
      Instance   : in out Watchdog_Instance;
      Config     : Watchdog_Configuration
   );

   --  Kick the watchdog (reset the timer)
   procedure Kick (Instance : in out Watchdog_Instance);

   --  Check if the watchdog has triggered
   function Has_Triggered (Instance : Watchdog_Instance) return Boolean;

   --  Get the current state of the watchdog
   function Get_State (Instance : Watchdog_Instance) return Watchdog_State;

   --  Disable the watchdog (for maintenance or shutdown)
   procedure Disable (Instance : in out Watchdog_Instance);

   --  Enable the watchdog (after initialization or disable)
   procedure Enable (Instance : in out Watchdog_Instance);

   --  Get the remaining time until the watchdog triggers
   function Time_Remaining (Instance : Watchdog_Instance) return Time_Span;

private

   --  Internal structure for the watchdog instance
   type Watchdog_Instance is record
      Config      : Watchdog_Configuration;
      Last_Kick   : Time := Clock_Epoch;  --  Last time the watchdog was kicked
      State       : Watchdog_State := Disabled;
   end record;

end Watchdog;
