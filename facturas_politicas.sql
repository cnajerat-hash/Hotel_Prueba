CREATE POLICY facturas_select_own ON facturas FOR SELECT
    USING (
        id_reserva IN (
            SELECT id_reserva FROM reservas
            WHERE auth_id_usuario =
			(SELECT auth_id FROM usuarios WHERE email = auth.email())
        )
    );

CREATE POLICY facturas_select_all_recep_admin ON facturas FOR SELECT
    USING (current_user_role() IN ('Recepcionista', 'Administrador'));

CREATE POLICY facturas_insert_own ON facturas FOR INSERT
    WITH CHECK (
        id_reserva IN (
            SELECT id_reserva FROM reservas
            WHERE auth_id_usuario =
			(SELECT auth_id FROM usuarios WHERE email = auth.email())
        )
        AND current_user_role() = 'Huesped'
	);

CREATE POLICY facturas_insert_recep_admin ON facturas FOR INSERT
    WITH CHECK (current_user_role() IN ('Recepcionista', 'Administrador'));

CREATE POLICY facturas_update_recep_admin ON facturas FOR UPDATE
    USING (current_user_role() IN ('Recepcionista', 'Administrador'));

CREATE POLICY facturas_delete_admin ON facturas FOR DELETE
    USING (current_user_role() = 'Administrador');
