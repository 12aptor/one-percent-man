import 'plan_model.dart';

class PlanTemplates {
  static List<Plan> get guerraTemplates => [
        Plan(
          id: 'tpl_guerra_phys',
          title: 'Guerra: El Guerrero',
          description: 'Forjar el cuerpo como herramienta de poder y autoridad.',
          hell: 'Un cuerpo débil que no proyecta respeto, baja energía y falta de autoridad física.',
          heaven: 'Un físico imponente forjado en el hierro, vitalidad explosiva y una presencia que domina cualquier habitación.',
          createdAt: DateTime.now(),
          objectives: [
            PlanObjective(id: 'g_p1', title: 'Entrenamiento de fuerza 5 días/semana'),
            PlanObjective(id: 'g_p2', title: 'Reducir % de grasa corporal a niveles atléticos'),
            PlanObjective(id: 'g_p3', title: 'Dominar postura y lenguaje corporal de poder'),
          ],
          missions: [
            MissionAction(id: 'gm_p1', content: 'Levantamiento de pesas/Fuerza', isDaily: false),
            MissionAction(id: 'gm_p2', content: 'Dieta alta en proteína y grasas sanas', isDaily: true),
            MissionAction(id: 'gm_p3', content: 'Cero azúcar y ultraprocesados', isDaily: true),
          ],
        ),
        Plan(
          id: 'tpl_guerra_fin',
          title: 'Guerra: Dominio Total',
          description: 'Excelencia profesional y construcción de activos financieros.',
          hell: 'Ser un trabajador promedio estancado, sin ahorros y dependiente de la aprobación ajena.',
          heaven: 'Dominio absoluto de tu rubro profesional, libertad financiera y una red de contactos de alto valor.',
          createdAt: DateTime.now(),
          objectives: [
            PlanObjective(id: 'g_f1', title: 'Dominar habilidad técnica (Top 1%)'),
            PlanObjective(id: 'g_f2', title: 'Invertir 20% de ingresos mensuales'),
            PlanObjective(id: 'g_f3', title: 'Construir red de contactos de alto valor'),
          ],
          missions: [
            MissionAction(id: 'gm_f1', content: '90 min Deep Work en habilidad técnica', isDaily: true),
            MissionAction(id: 'gm_f2', content: 'Networking: Contactar 1 mentor/compa', isDaily: false),
            MissionAction(id: 'gm_f3', content: 'Estudio de mercados/finanzas', isDaily: true),
          ],
        ),
        Plan(
          id: 'tpl_guerra_soc',
          title: 'Guerra: Límites de Hierro',
          description: 'Independencia emocional y respeto social inquebrantable.',
          hell: 'Ser un hombre complaciente que busca validación externa y no sabe decir "No".',
          heaven: 'Respeto social inquebrantable, relaciones de alto valor y total independencia emocional.',
          createdAt: DateTime.now(),
          objectives: [
            PlanObjective(id: 'g_s1', title: 'Eliminar necesidad de validación externa'),
            PlanObjective(id: 'g_s2', title: 'Establecer límites claros en relaciones'),
            PlanObjective(id: 'g_s3', title: 'Priorizar progreso sobre ocio vacío'),
          ],
          missions: [
            MissionAction(id: 'gm_s1', content: 'Cero likes de validación en redes', isDaily: true),
            MissionAction(id: 'gm_s2', content: 'Decir "No" a 1 situación incómoda', isDaily: false),
            MissionAction(id: 'gm_s3', content: 'Análisis de prioridades sociales', isDaily: false),
          ],
        ),
      ];

  static List<Plan> get monjeTemplates => [
        Plan(
          id: 'tpl_monje_proj',
          title: 'Monje: Proyecto Maestro',
          description: 'Enfoque absoluto en un objetivo masivo de vida.',
          hell: 'Tener mil ideas y no terminar ninguna, vivir distraído y con la mente fragmentada.',
          heaven: 'Completar un objetivo masivo que cambie tu vida para siempre.',
          createdAt: DateTime.now(),
          objectives: [
            PlanObjective(id: 'm_p1', title: 'Lanzar negocio / Aprender código / Meta masiva'),
            PlanObjective(id: 'm_p2', title: 'Eliminar distracciones secundarias'),
            PlanObjective(id: 'm_p3', title: 'Documentar proceso en Journal del Monje'),
          ],
          missions: [
            MissionAction(id: 'mm_p1', content: '4 horas foco en Proyecto Maestro', isDaily: true),
            MissionAction(id: 'mm_p2', content: 'Auditoría de progreso en Journal', isDaily: true),
            MissionAction(id: 'mm_p3', content: 'Planificación estratégica diaria', isDaily: true),
          ],
        ),
        Plan(
          id: 'tpl_monje_vicios',
          title: 'Monje: Cero Vicios',
          description: 'Reinicio mental y control total sobre la dopamina.',
          hell: 'Esclavo de la dopamina barata, mente nublada y falta de voluntad.',
          heaven: 'Claridad mental absoluta, control total sobre los impulsos y una voluntad de acero.',
          createdAt: DateTime.now(),
          objectives: [
            PlanObjective(id: 'm_v1', title: 'Racha de 90 días libre de vicios'),
            PlanObjective(id: 'm_v2', title: 'Recuperar sensibilidad a la dopamina'),
            PlanObjective(id: 'm_v3', title: 'Control mental mediante meditación'),
          ],
          missions: [
            MissionAction(id: 'mm_v1', content: 'Cero porno, alcohol, chatarra', isDaily: true),
            MissionAction(id: 'mm_v2', content: 'Cero redes sociales de ocio', isDaily: true),
            MissionAction(id: 'mm_v3', content: 'Meditación/Introspección 15 min', isDaily: true),
          ],
        ),
        Plan(
          id: 'tpl_monje_wisdom',
          title: 'Monje: Sabiduría del Silencio',
          description: 'Autoconocimiento profundo y sabiduría técnica.',
          hell: 'Vivir en el ruido constante, sin conocerse a uno mismo.',
          heaven: 'Autoconocimiento profundo y paz interior inquebrantable.',
          createdAt: DateTime.now(),
          objectives: [
            PlanObjective(id: 'm_w1', title: 'Leer 12 libros de filosofía/técnicos'),
            PlanObjective(id: 'm_w2', title: 'Desarrollar hábito de Journaling nocturno'),
            PlanObjective(id: 'm_w3', title: 'Práctica de silencio total diario'),
          ],
          missions: [
            MissionAction(id: 'mm_w1', content: 'Lectura profunda (45 min)', isDaily: true),
            MissionAction(id: 'mm_w2', content: 'Journaling: Debilidades y victorias', isDaily: true),
            MissionAction(id: 'mm_w3', content: '1 hora de silencio total (sin digital)', isDaily: true),
          ],
        ),
      ];

  static List<Plan> get premiumTemplates => [...guerraTemplates, ...monjeTemplates];
}

