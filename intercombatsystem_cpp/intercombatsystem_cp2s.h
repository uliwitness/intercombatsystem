// This file was auto-generated by cpptoswift.
// Do not edit this file, edit the original source file /Users/uli/Programming/intercombatsystem/intercombatsystem_cpp/intercombatsystem.hpp

#if __cplusplus
extern "C"
{
#endif /* __cplusplus */

typedef struct intercombatactor intercombatactor;

void intercombatactor_deinit( intercombatactor* _this );
intercombatactor* intercombatactor_init( void );
void intercombatactor_turn_by_radians( intercombatactor* _this,  double radians );
double intercombatactor_radian_angle_to_actor( intercombatactor* _this,  intercombatactor* target );
double intercombatactor_distance_to_actor( intercombatactor* _this,  intercombatactor* target );
double intercombatactor_get_angle( intercombatactor* _this );
double intercombatactor_get_x( intercombatactor* _this );
void intercombatactor_set_x( intercombatactor* _this,  double inX );
double intercombatactor_get_y( intercombatactor* _this );
void intercombatactor_set_y( intercombatactor* _this,  double inY );

#if __cplusplus
}
#endif /* __cplusplus */