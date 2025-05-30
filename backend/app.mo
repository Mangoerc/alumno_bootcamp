import Map "mo:base/HashMap";
import Text "mo:base/Text";
import Iter "mo:base/Iter";
import Array "mo:base/Array";

actor prueba {

  // alumno → (materia → calificación)
  let grupoA = Map.HashMap<Text, Map.HashMap<Text, Text>>(0, Text.equal, Text.hash);

  // Crear o actualizar una materia y calificación para un alumno
  public func crear_registro(calificacion: Text, materia: Text, alumno: Text) {
    let materiasDelAlumno = switch (grupoA.get(alumno)) {
      case (?mapa) { mapa };
      case null { Map.HashMap<Text, Text>(0, Text.equal, Text.hash) };
    };
    materiasDelAlumno.put(materia, calificacion);
    grupoA.put(alumno, materiasDelAlumno);
  };

  // Obtener todas las materias y calificaciones de un alumno
  public query func obtener_alumno(alumno: Text): async Text {
    switch (grupoA.get(alumno)) {
      case (?materias) {
        let lista: [(Text, Text)] = Iter.toArray(materias.entries());
        let texto: Text = Array.foldLeft<(Text, Text), Text>(
          lista,
          "",
          func(acum: Text, entrada: (Text, Text)): Text {
            let (mat, calif) = entrada;
            acum # "Materia: " # mat # ", Calificación: " # calif # "\n";
          }
        );
        return texto;
      };
      case null {
        return "Alumno no encontrado.";
      };
    };
  };

  // Eliminar completamente a un alumno
  public func dar_de_baja(alumno: Text): async Text {
    switch (grupoA.remove(alumno)) {
      case (?_) { "Alumno dado de baja." };
      case null { "Alumno no encontrado."; };
    }
  };

  // Eliminar solo una materia del alumno
  public func borrar_materia(alumno: Text, materia: Text): async Text {
    switch (grupoA.get(alumno)) {
      case (?materias) {
        switch (materias.remove(materia)) {
          case (?_) {
            let materiasRestantes = Iter.toArray(materias.keys());
            if (Array.size(materiasRestantes) == 0) {
              ignore grupoA.remove(alumno);
              return "Materia eliminada. El alumno ya no tiene materias y fue dado de baja.";
            } else {
              return "Materia eliminada del alumno.";
            }
          };
          case null { return "Materia no encontrada para ese alumno."; };
        }
      };
      case null { return "Alumno no encontrado."; };
    };
  };

  // Listar todos los alumnos registrados
  public query func obtener_estudiantes(): async [Text] {
    Iter.toArray(grupoA.keys());
  };
}
