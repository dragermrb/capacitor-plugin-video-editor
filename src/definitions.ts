export interface VideoEditorPlugin {
  echo(options: { value: string }): Promise<{ value: string }>;
}
