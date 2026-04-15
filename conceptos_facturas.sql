CREATE POLICY conceptos_select_own ON conceptos_facturas FOR SELECT
    USING (
        id_factura IN (
            SELECT id_factura FROM facturas
            WHERE id_reserva IN (
                SELECT id_reserva FROM reservas
                WHERE id_usuario = (SELECT id_usuario FROM usuarios WHERE email = auth.email())
            )
        )
    );

CREATE POLICY conceptos_select_all_recep_admin ON conceptos_facturas FOR SELECT
    USING (current_user_role() IN ('Recepcionista', 'Administrador'));

CREATE POLICY conceptos_insert_recep_admin ON conceptos_facturas FOR INSERT
    WITH CHECK (current_user_role() IN ('Recepcionista', 'Administrador'));

CREATE POLICY conceptos_update_recep_admin ON conceptos_facturas FOR UPDATE
    USING (current_user_role() IN ('Recepcionista', 'Administrador'));

CREATE POLICY conceptos_delete_admin ON conceptos_facturas FOR DELETE
    USING (current_user_role() = 'Administrador');
