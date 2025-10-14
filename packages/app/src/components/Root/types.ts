export type DynamicPluginsConfig = {
  frontend: {
    [key: string]: {
        dynamicRoutes?: DynamicRoute[];
        entityTabs?: EntityTab[];
        mountPoints?: MountPoint[];
      };
  }
};

export type DynamicRoute = {
  importName: string;
  menuItem?: MenuItem;
  path: string;
};

export type MenuItem = {
  icon: string;
  text: string;
};

export type EntityTab = {
  mountPoint: string;
  path: string;
  title: string;
};

export type MountPoint = {
  config: MountPointConfig;
};

export type MountPointConfig = {
  if: {
    [key: string]: string | string[];
  };
  layout: {
    [key: string]:
      | string
      | {
          [key: string]: string;
        };
  };
  importName: string;
  moutPoint: string;
};
