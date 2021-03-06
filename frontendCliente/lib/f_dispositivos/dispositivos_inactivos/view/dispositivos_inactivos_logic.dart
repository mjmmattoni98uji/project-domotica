import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:focused_menu/modals.dart';
import 'package:frontendCliente/f_dispositivos/dispositivos_inactivos/dispositivos_inactivos.dart';
import 'package:room_repository/device_repository.dart';
import 'package:room_repository/room_repository.dart';

class DispositivosInactivosLogic extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return _DispositivosInactivosLogicState();
  }
}

class _DispositivosInactivosLogicState extends State<DispositivosInactivosLogic> {

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InactivoBloc, InactivoState>(
        builder: (context, state) {
          if(state is InactivosActuales) {
            return ListView.builder(
              addAutomaticKeepAlives: true,
              physics: BouncingScrollPhysics( parent: AlwaysScrollableScrollPhysics() ),
              itemCount: state.dispositivos.length,
              itemBuilder: (_, int index) {
                return Padding(
                  padding: EdgeInsets.all(5.0),
                  child: Container(
                    child: Card(
                      elevation: 10.0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0)),
                      child: FocusedMenuHolder(
                          blurBackgroundColor: Colors.white38,
                          blurSize: 2.0,
                          animateMenuItems: true,
                          openWithTap: true,
                          onPressed: () {},
                          menuItems: <FocusedMenuItem>[
                            FocusedMenuItem(
                                trailingIcon: Icon(
                                    Icons.assignment_return_outlined
                                ),
                                title: Text(
                                  "Asignar habitación",
                                  style: TextStyle(
                                      fontFamily: "Raleway"
                                  ),
                                ),
                                onPressed: () {
                                  buildGeneralDialog(context, state.habitaciones, state.dispositivos[index]);
                                }
                            )
                          ],

                          child: ListTile(
                            title: Text(state.dispositivos[index].nombre,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 20.0,
                                fontFamily: "Raleway",
                              ),
                            ),
                          )
                      ),
                    ),
                  ),
                );
              },
            );
          }else if(state is InactivoInitial){
            context.bloc<InactivoBloc>().add(InactivosStarted());
          }else if(state is ListaInactivoError){
            return Center(
              child: Text("No hay dispositivos existentes inactivos",
                textAlign: TextAlign.center,
                style: TextStyle(fontFamily: "Raleway"),
              ),
            );
          }
          return Center(child: CircularProgressIndicator(),);
        }
        );
  }


  void buildGeneralDialog(BuildContext context, List<Room> habitaciones, Device dispositivo){
    AwesomeDialog(
        animType: AnimType.SCALE,
        borderSide: BorderSide(color: Colors.black54, width: 5),
      dismissOnTouchOutside: true,
      padding: EdgeInsets.all(8.0),
      context: context,
      dialogType: DialogType.QUESTION,
      dismissOnBackKeyPress: true,
      headerAnimationLoop: false,
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width - 75,
          height: MediaQuery.of(context).size.height - 100,
          child: ListView.builder(
            addAutomaticKeepAlives: true,
            physics: BouncingScrollPhysics( parent: AlwaysScrollableScrollPhysics() ),
            itemCount: habitaciones.length,
            itemBuilder: (_, index2){
              return ListTile(
                onTap: (){
                  context.bloc<InactivoBloc>().add(AsignarHabitacion(dispositivo.id, habitaciones[index2].id));
                  Navigator.pop(context);
                },
                title: Text(habitaciones[index2].nombre, style: TextStyle(
                  fontFamily: "Raleway",
                ),
                  textAlign: TextAlign.center,
                ),
              );
            },
          ),
        ),
      )
    )..show();
  }
}