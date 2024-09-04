import 'package:sic4change/services/models_drive.dart';

void createProjectFolders(Folder root) {
  Folder f1 = Folder("Formulación", root.uuid);
  f1.save();
  Folder f11 = Folder("Análisis", f1.uuid);
  f11.save();
  Folder f12 = Folder("Bases", f1.uuid);
  f12.save();
  Folder f13 = Folder("Modelos", f1.uuid);
  f13.save();
  Folder f14 = Folder("Entregados", f1.uuid);
  f14.save();
  Folder f141 = Folder("Anexos rellenados", f14.uuid);
  f141.save();
  Folder f142 = Folder("Anexos solicitados", f14.uuid);
  f142.save();
  Folder f143 = Folder("Otros anexos", f14.uuid);
  f143.save();

  Folder f2 = Folder("Administrativo", root.uuid);
  f2.save();
  Folder f21 = Folder("Carta de aprobación", f2.uuid);
  f21.save();
  Folder f22 = Folder("Carta de cierre", f2.uuid);
  f22.save();
  Folder f23 = Folder("Contratos", f2.uuid);
  f23.save();
  Folder f231 = Folder("Subcontratación", f23.uuid);
  f231.save();
  Folder f232 = Folder("Socio", f23.uuid);
  f232.save();
  Folder f24 = Folder("Comunicación financiador", f2.uuid);
  f24.save();
  Folder f241 = Folder("Requerimiento", f24.uuid);
  f241.save();
  Folder f242 = Folder("Reformulación", f24.uuid);
  f242.save();
  Folder f243 = Folder("Solicitud de subcontratación", f24.uuid);
  f243.save();
  Folder f244 = Folder("Información", f24.uuid);
  f244.save();

  Folder f3 = Folder("Ejecución", root.uuid);
  f3.save();
  Folder f31 = Folder("Procedimientos", f3.uuid);
  f31.save();
  Folder f32 = Folder("Actividades", f3.uuid);
  f32.save();
  Folder f33 = Folder("Material Comunicación", f3.uuid);
  f33.save();
  Folder f331 = Folder("Logo financiadores", f33.uuid);
  f331.save();
  Folder f332 = Folder("Logo socios", f33.uuid);
  f332.save();
  Folder f333 = Folder("Materiales", f33.uuid);
  f333.save();
  Folder f334 = Folder("Copy", f33.uuid);
  f334.save();

  Folder f4 = Folder("M&E", root.uuid);
  f4.save();
  Folder f41 = Folder("Cuadro de mandos y BBDD", f4.uuid);
  f41.save();
  Folder f42 = Folder("FFVV", f4.uuid);
  f42.save();

  Folder f5 = Folder("Contabilidad", root.uuid);
  f5.save();
  Folder f51 = Folder("Informe financiero", f5.uuid);
  f51.save();
  Folder f52 = Folder("Facturas justificativas", f5.uuid);
  f52.save();
  Folder f53 = Folder("Datos bancarios", f5.uuid);
  f53.save();

  Folder f6 = Folder("Justificación", root.uuid);
  f6.save();
  Folder f61 = Folder("Instrucciones", f6.uuid);
  f61.save();
  Folder f62 = Folder("Modelos", f6.uuid);
  f62.save();
  Folder f63 = Folder("Rellenos", f6.uuid);
  f63.save();
  Folder f64 = Folder("Entregado", f6.uuid);
  f64.save();
  Folder f65 = Folder("Aprobación", f6.uuid);
  f65.save();
}
