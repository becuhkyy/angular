/**
 * @module
 * @description
 * Starting point to import all public core APIs.
 */
export * from './src/core/metadata';
export * from './src/core/util';
export * from './src/core/prod_mode';
export * from './src/core/di';
export * from './src/facade/facade';
export {enableProdMode} from './src/facade/lang';
export {
  createPlatform,
  assertPlatform,
  disposePlatform,
  getPlatform,
  coreBootstrap,
  coreLoadAndBootstrap,
  createNgZone,
  PlatformRef,
  ApplicationRef
} from './src/core/application_ref';
export {
  APP_ID,
  APP_INITIALIZER,
  PACKAGE_ROOT_URL,
  PLATFORM_INITIALIZER
} from './src/core/application_tokens';
export * from './src/core/zone';
export * from './src/core/render';
export * from './src/core/linker';
export {DebugElement, DebugNode, asNativeElements, getDebugNode} from './src/core/debug/debug_node';
export {DebugDomRootRenderer} from './src/core/debug/debug_renderer';
export * from './src/core/testability/testability';
export * from './src/core/change_detection';
export * from './src/core/platform_directives_and_pipes';
export * from './src/core/platform_common_providers';
export * from './src/core/application_common_providers';
export * from './src/core/reflection/reflection';

export * from './private_export';