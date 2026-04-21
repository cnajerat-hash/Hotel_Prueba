CREATE POLICY reservas_select_own ON reservas FOR SELECT
    USING (auth_id_usuario = (SELECT auth_id FROM usuarios WHERE email = auth.email()));

CREATE POLICY reservas_select_all_recep_admin ON reservas FOR SELECT
    USING (current_user_role() IN ('Recepcionista', 'Administrador'));

CREATE POLICY reservas_insert_own ON reservas FOR INSERT
    WITH CHECK (
        auth_id_usuario = (SELECT auth_id FROM usuarios WHERE email = auth.email())
        AND current_user_role() = 'Huesped'
    );

CREATE POLICY reservas_insert_recep_admin ON reservas FOR INSERT
    WITH CHECK (current_user_role() IN ('Recepcionista', 'Administrador'));

CREATE POLICY reservas_update_own ON reservas FOR UPDATE
    USING (
        auth_id_usuario = (SELECT auth_id FROM usuarios WHERE email = auth.email())
        AND estado = 'Pendiente'
    )
    WITH CHECK (estado IN ('Pendiente', 'Cancelada'));

CREATE POLICY reservas_update_recep_admin ON reservas FOR UPDATE
    USING (current_user_role() IN ('Recepcionista', 'Administrador'));

CREATE POLICY reservas_delete_admin ON reservas FOR DELETE
    USING (current_user_role() = 'Administrador');
